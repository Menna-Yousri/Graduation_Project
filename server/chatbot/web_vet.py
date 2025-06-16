import os
from dotenv import load_dotenv
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain_core.prompts import ChatPromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI

# Load .env
load_dotenv()
os.environ["TAVILY_API_KEY"] = os.getenv("TAVILY_API_KEY")
os.environ["GOOGLE_API_KEY"] = os.getenv("GOOGLE_API_KEY")

# Tavily Search Setup
search_tool = TavilySearchResults(max_results=10, search_depth="advanced")

# Gemini Setup
llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash-exp",
    temperature=0.0,  # zero = most deterministic and factual
    max_output_tokens=2048,
)

# System Prompt
system_prompt = """
You are a factual assistant. Answer ONLY using the following search results.

Instructions:
- Do NOT include any information that is not directly found in the results.
- If the answer is not in the context, say: **"The search results do not contain this information."**
- Be precise, concise, and well-structured.
- Do NOT hallucinate.
- Always include the source URL at the end of relevant sentences using the format (source: URL).
- Use **bold** for key terms, bullet points for lists, and a heading that repeats the question.
- End your response with a **brief summary** of the answer in 1–2 sentences.

SEARCH RESULTS:
{context}
"""


prompt = ChatPromptTemplate.from_messages([
    ("system", system_prompt.strip()),
    ("human", "{input}")
])

def run_web_search(question: str) -> str:
    try:
        search_results = search_tool.invoke(question)
    except Exception as e:
        return f"❌ Error during search: {e}"

    # Filter & Clean
    seen_urls = set()
    filtered = []
    for res in search_results:
        url, content = res.get("url"), res.get("content", "").strip()
        if url and content and len(content) > 100 and url not in seen_urls:
            seen_urls.add(url)
            filtered.append(res)

    if not filtered:
        return "**The search results do not contain this information.**"

    # Format Context
    formatted_context = "\n\n".join([
        f"- {res['content'].rstrip().rstrip('.')}.\n\n  (source: {res['url']})"
        for res in filtered
    ])

    heading = f"## {question.strip()}"
    full_input = f"{heading}\n\n{question.strip()}"

    input_vars = {
        "context": formatted_context,
        "input": full_input
    }

    try:
        chain = prompt | llm
        response = chain.invoke(input_vars)
    except Exception as e:
        return f"❌ Error during generation: {e}"

    return response.content.strip()

# Test Block
if __name__ == "__main__":
    question = "What are clinical signs and treatment options for Summer Mastitis?"
    print("\n❓ Question:\n")
    print(question)
    answer = run_web_search(question)
    print("\n✅ Final Answer:\n")
    print(answer)
