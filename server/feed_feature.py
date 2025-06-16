import os
import json
from datetime import datetime
from typing import List, Optional, Dict, Literal

from fastapi import HTTPException # Used for API error handling
from crewai import Agent, Task, Crew, Process, LLM
from crewai.tools import tool
from tavily import TavilyClient
from scrapegraph_py import Client
import agentops

# Import Pydantic models from schemas.py
from schemas import (
    CowProfileRequest,
    IdealFeedFormulation,
    FeedComparisonReport,
    SuggestedSearchQueries,
    FeedProductResult,
    BestFeedRecommendationOutput,
    IdealFeedFormulationResponse,
    FeedComparisonReportResponse,
    BestFeedRecommendationOutputResponse
)

# --- CrewAI Process Execution Function ---
async def run_crew_process(cow_profile_data: CowProfileRequest):
    """
    Initializes CrewAI agents and tasks, and kicks off the process
    based on the provided cow profile data. Reads outputs from files.
    """
    # Load API keys from environment variables
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    TAVILY_API_KEY = os.getenv('TAVILY_API_KEY')
    SCRAPEGRAPH_API_KEY = os.getenv('SCRAPEGRAPH_API_KEY')
    AGENTOPS_API_KEY = os.getenv('AGENTOPS_API_KEY')

    # Validate API keys
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY environment variable not set.")
    if not TAVILY_API_KEY:
        raise HTTPException(status_code=500, detail="TAVILY_API_KEY environment variable not set.")
    if not SCRAPEGRAPH_API_KEY:
        raise HTTPException(status_code=500, detail="SCRAPEGRAPH_API_KEY environment variable not set.")

    # Initialize AgentOps if API key is available
    if AGENTOPS_API_KEY:
        agentops.init(
            api_key=AGENTOPS_API_KEY,
            skip_auto_end_session=True,
            default_tags=['crewai_fastapi']
        )
    else:
        print("AGENTOPS_API_KEY not found. AgentOps will not be initialized.")

    # Initialize LLM and external clients
    basic_llm = LLM(
        model="gemini/gemini-2.0-flash",
        temperature=0.2,
        api_key=GEMINI_API_KEY
    )
    search_client = TavilyClient(api_key=TAVILY_API_KEY)
    scrape_client = Client(api_key=SCRAPEGRAPH_API_KEY)

    # Define the search tool (needs to be defined after search_client is initialized)
    @tool
    def search_engine_tool(query: str):
        """
        Tool for searching the internet to find cow feed formulations.
        Ensures that pages display real products with name, ingredients, and price.
        """
        results = search_client.search(query=query)
        return json.dumps(results)

    # --- Define Agents ---
    feed_agent = Agent(
        role="خبير تغذية ماشية",
        goal=(
            "تحليل حالة البقرة وإنتاج توليفة علف مناسبة بناءً على العمر، الوزن، النوع، الهدف الإنتاجي، "
            "كمية الحليب المنتجة، حالة الحمل، السلالة، العلف المستخدم حالياً، مستوى النشاط البدني، "
            "الحالة الصحية والموسم."
        ),
        backstory=(
            "خبير في تغذية الأبقار لديه خبرة كبيرة في تصميم الأعلاف وتوصية بالتغذية المثالية، "
            "مع معرفة دقيقة بمصادر الأعلاف المحلية ومكونات العليقة."
        ),
        llm=basic_llm,
        verbose=True
    )

    balance_check_agent = Agent(
        role="خبير تغذية للتحقق من توازن العلف",
        goal="قارن العلف المستخدم بالتوليفة المثالية واذكر العناصر الناقصة والزائدة مع تقديم تقرير مفصل.",
        backstory=(
            "خبير تغذية متخصص في اكتشاف الفجوات بين العلف الفعلي والتغذية المثالية المطلوبة، "
            "مع تقديم توصيات لتحسين التوازن الغذائي."
        ),
        llm=basic_llm,
        verbose=True,
    )

    feed_keyword_generator_agent = Agent(
        role="مولد كلمات البحث العلفي",
        goal=(
            "توليد قائمة متنوعة من العبارات البحثية المتعلقة بتوليفات الأعلاف الحيوانية. "
            "يجب أن تكون العبارات دقيقة وتشمل مكونات أو براندات أو تقنيات معينة."
        ),
        backstory=(
            "هذا الوكيل مصمم لمساعدة المزارعين أو الباحثين في العثور على أفضل توليفات العلف عبر الإنترنت، "
            "بناءً على نوع الحيوان والهدف الإنتاجي."
        ),
        llm=basic_llm,
        verbose=True,
    )

    search_engine_agent = Agent(
        role="وكيل البحث عن توليفات علف الأبقار",
        goal=(
            "البحث على الإنترنت عن صفحات متاجر إلكترونية تبيع توليفات علف مثالية للأبقار فقط. "
            "يجب استخراج اسم المنتج، مكوناته مع نسبها، والسعر."
        ),
        backstory=(
            "هذا الوكيل مسؤول عن جمع صفحات منتجات علف الأبقار الحقيقية من الإنترنت "
            "لاستخدامها في مقارنة الأسعار والمكونات لترشيح أفضل توليفة."
        ),
        llm=basic_llm,
        verbose=True,
        tools=[search_engine_tool]
    )

    procurement_report_author_agent = Agent(
        role="وكيل ترشيح أفضل المنتجات",
        goal="تقييم المنتجات واختيار الأفضل من حيث القيمة مقابل السعر.",
        backstory="يملك خبرة في تحليل المواصفات والأسعار لاختيار أفضل قيمة للمستخدم.",
        llm=basic_llm,
        verbose=True
    )

    # --- Ensure output directory exists ---
    output_dir = "./ai-agent-output"
    os.makedirs(output_dir, exist_ok=True)

    # --- Assign default values for optional fields if not provided by the user ---
    # This ensures CrewAI tasks have the necessary context even if user doesn't send these.
    cow_profile_data.activity_level = cow_profile_data.activity_level or "low"
    cow_profile_data.health_status = cow_profile_data.health_status or "good"
    cow_profile_data.season = cow_profile_data.season or "winter"
    cow_profile_data.animal_type = cow_profile_data.animal_type or "البقرة"
    cow_profile_data.production_goal = cow_profile_data.production_goal or "زيادة إنتاج اللحوم"
    cow_profile_data.country_name = cow_profile_data.country_name or "Egypt"
    cow_profile_data.product_name = cow_profile_data.product_name or "livestock nutrition"
    cow_profile_data.no_keywords = cow_profile_data.no_keywords or 10
    cow_profile_data.language = cow_profile_data.language or "Arabic"
    cow_profile_data.score_th = cow_profile_data.score_th or 0.7

    # Prepare input dictionary for CrewAI kickoff using the potentially updated cow_profile_data
    crew_inputs = cow_profile_data.dict(by_alias=True)

    # --- Define Tasks (with dynamic descriptions using f-strings for inputs) ---
    feed_task = Task(
        description=f"""
        بناءً على بيانات البقرة التالية:
        - النوع: {crew_inputs['type']}
        - العمر: {crew_inputs['age']} سنة
        - الوزن: {crew_inputs['weight']} كجم
        - الهدف: {crew_inputs['goal']}
        - إنتاج الحليب: {crew_inputs['milk_yield']} لتر/يوم
        - السلالة: {crew_inputs['breed']}
        - العلف المستخدم: {crew_inputs['current_feed']}
        قم بإنشاء توليفة علف مثالية تحتوي على:
        - العلف الخشن (مثل البرسيم، الذرة الشامية)
        - العلف المركز (مثل الذرة، فول الصويا)
        - المكملات الغذائية (مثل المعادن والفيتامينات)
        - كمية المياه اليومية

        جميع الكميات هي يومية لكل بقرة.

        يجب أن يحتوي كل عنصر على:
        - نوع العلف
        - الكمية بالكيلو جرام أو الليتر
        - نسبة البروتين (إن وجدت)
        - ملاحظات عملية للمربي وتكتب باللغه {crew_inputs['language']}
        """,
        expected_output="JSON",
        output_json=IdealFeedFormulation,
        output_file=os.path.join(output_dir, "step_1_feed_recommendation.json"),
        agent=feed_agent
    )

    balance_check_task = Task(
        description=f"""
        قارن بين العلف الحالي والتوليفة المثالية.
        حدد فقط **أبرز 3–5 نواقص أو فائضات غذائية**.
        اكتب التقرير باللغة {crew_inputs['language']} باستخدام نقاط واضحة:
        - ما هو النقص أو الزيادة؟
        - كيف يؤثر ذلك على الإنتاج؟
        - ما الحل المقترح؟
        - ما هي التكلفة الإضافية المتوقعة؟
        """,
        expected_output="JSON",
        output_json=FeedComparisonReport,
        output_file=os.path.join(output_dir, "step_2_feed_balance_check.json"),
        agent=balance_check_agent
    )

    feed_keyword_generation_task = Task(
        description=f"""
        استنادًا إلى التوليفة العلفية المثالية التي تم إنشاؤها في الخطوة الأولى:

        - اقرأ ملف `step_1_feed_recommendation.json`
        - استخرج مكونات التوليفة (العلف الخشن، المركز، البروتين، المكملات)
        - ولّد كلمات بحث باللغة {crew_inputs['language']} تساعد في العثور على منتجات أعلاف متاحة محليًا
        - ركّز فقط على أعلاف الأبقار التي هي النوع: {crew_inputs['type']}
        - العمر: {crew_inputs['age']} سنة
        - الوزن: {crew_inputs['weight']} كجم
        - الهدف: {crew_inputs['goal']}
        - السلالة: {crew_inputs['breed']} – لا تشمل الدواجن أو الأسماك
        - يجب أن تشير الكلمات إلى مكونات واضحة مثل نسبة البروتين أو نوع العلف
        استخرج {crew_inputs['no_keywords']} كلمات مفتاحية.
        """,
        expected_output="JSON",
        output_json=SuggestedSearchQueries,
        output_file=os.path.join(output_dir, "step_3_feed_search_keywords.json"),
        agent=feed_keyword_generator_agent
    )

    task_search_products = Task(
        description=f"""
        استخدم الكلمات المفتاحية لتنفيذ بحث عبر الإنترنت عن أعلاف الأبقار.
        يجب أن تشمل كل نتيجة:
        - اسم المنتج
        - نسبة البروتين
        - سعر الكيلوغرام
        - قائمة بالمكونات الرئيسية
        - تقييم البائع (من 0 إلى 5 إن أمكن)
        - رابط المنتج
        تجاهل أي نتائج غير موثوقة أو بدون مواصفات كاملة.
        أهم حاجة تستخرج من البلد {crew_inputs['country_name']} واللغة {crew_inputs['language']}.
        """,
        expected_output="JSON",
        output_json=FeedProductResult,
        output_file=os.path.join(output_dir, "step_4_feed_search_results.json"),
        agent=search_engine_agent
    )

    task_recommend_product = Task(
        description=f"""
        قم بتقييم جميع المنتجات التي نتجت من الوكيل السابق وفقاً لمدى تطابق مواصفاتها مع التوليفة المثالية.
        لا تجلب عناوين URL وهمية، يجب التحقق من أنها حقيقية وشغالة، لو لم تكن شغالة اهملها.
        يجب مقارنة **3 منتجات على الأقل**، ويتم اختيار **أفضل منتج واحد فقط**.
        تأكد أن كل النواتج وعناوين URL تكون داخل دولة {crew_inputs['country_name']}، يجب التأكد من ذلك.
        اعرض التوصية بصيغة جدول بسيطة باللغة {crew_inputs['language']}.
        """,
        expected_output="JSON",
        output_json=BestFeedRecommendationOutput,
        output_file=os.path.join(output_dir, "step_5_procurement_recommendation.json"),
        agent=procurement_report_author_agent
    )

    # Define the list of tasks for the Crew
    tasks = [
        feed_task,
        balance_check_task,
        feed_keyword_generation_task,
        task_search_products,
        task_recommend_product
    ]

    # Initialize the Crew
    cow_feed_optimization_crew = Crew(
        agents=[
            feed_agent,
            balance_check_agent,
            feed_keyword_generator_agent,
            search_engine_agent,
            procurement_report_author_agent
        ],
        tasks=tasks,
        manager_llm=basic_llm,
        verbose=True,
        process=Process.sequential
    )

    # Kick off the CrewAI process
    try:
        cow_feed_optimization_crew.kickoff(inputs=crew_inputs)
        print("CrewAI process completed successfully.")
    except Exception as e:
        print(f"Error running CrewAI process: {e}")
        raise HTTPException(status_code=500, detail=f"Error running CrewAI process: {e}")

    # Read the generated output files
    try:
        with open(os.path.join(output_dir, "step_1_feed_recommendation.json"), 'r', encoding='utf-8') as f:
            feed_recommendation_data = json.load(f)
        with open(os.path.join(output_dir, "step_2_feed_balance_check.json"), 'r', encoding='utf-8') as f:
            feed_balance_check_data = json.load(f)
        with open(os.path.join(output_dir, "step_5_procurement_recommendation.json"), 'r', encoding='utf-8') as f:
            best_feed_recommendation_data = json.load(f)
    except FileNotFoundError as e:
        raise HTTPException(status_code=500, detail=f"Output file not found: {e}. Ensure CrewAI generated it.")
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"Error decoding JSON from output file: {e}. File might be corrupted or empty.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An unexpected error occurred while reading output files: {e}")

    current_datetime = datetime.now()
    generated_date = current_datetime.strftime("%Y-%m-%d")
    generated_time = current_datetime.strftime("%H:%M:%S")

    # Construct Pydantic response models with the generated timestamp
    feed_recommendation_response = IdealFeedFormulationResponse(
        **feed_recommendation_data,
        generated_date=generated_date,
        generated_time=generated_time
    )
    feed_balance_check_response = FeedComparisonReportResponse(
        **feed_balance_check_data,
        generated_date=generated_date,
        generated_time=generated_time
    )
    best_feed_recommendation_response = BestFeedRecommendationOutputResponse(
        **best_feed_recommendation_data,
        generated_date=generated_date,
        generated_time=generated_time
    )

    return {
        "feed_recommendation": feed_recommendation_response,
        "feed_balance_check": feed_balance_check_response,
        "best_feed_recommendation": best_feed_recommendation_response
    }