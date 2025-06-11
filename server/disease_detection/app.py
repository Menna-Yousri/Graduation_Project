import os
from dotenv import load_dotenv
import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
import re
import json

# Import classifier functions
from disease_detection.Models.Inference.Lumpy_Skin_Classification_Inferencing import LumpyDiseasesClassification
from disease_detection.Models.Inference.Mastitis_Classifiacation_Inferencing import MastitisDiseasesClassification

if "GOOGLE_API_KEY" not in os.environ:
    os.environ["GOOGLE_API_KEY"] = "AIzaSyCntXoGMZuqtGFFuXwWpEANQYAqTZ16LnA"

def infer_abdominal_lumpy(image_path):
    model_path = r"disease_detection/Models/Model/Lumpy_Skin_Disease_Classification_Model.pth"
    lumpy_detector = LumpyDiseasesClassification(model_path=model_path, class_names = ['Lumpy Skin', 'Normal Skin'])
    result = lumpy_detector.infer(image_path)
    description = (
        "The system monitors key diseases in cows, including Lumpy Skin Disease, providing farmers with early "
        "disease detection alerts. "
        "The output includes a prediction dictionary indicating the presence (1) or absence (0) of the diseases, along with "
        "confidence scores for each prediction."
    )

    return result, description


def infer_abdominal_mastitis(image_path):
    model_path = r"disease_detection\Models\Model\Mastitis_Disease_Classification_Model.pth"
    mastitis_detector = LumpyDiseasesClassification(model_path=model_path,class_names = ["Normal", "Infected"])
    result = mastitis_detector.infer(image_path)
    description = (
        "The system monitors key diseases in cows, including Mastitis  Disease, providing farmers with early "
        "disease detection alerts. "
        "The output includes a prediction dictionary indicating the presence (1) or absence (0) of the diseases, along with "
        "confidence scores for each prediction."
    )

    return result, description


def generate_disease_report(classifier_description, classifier_outputs, cow_id, timestamp, disease_detected):
    llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash-exp")

    template = """
    You are an expert veterinary report generator specializing in livestock disease detection through AI image classification and IoT-based monitoring. Based on the following data, generate a professional health report to be delivered to the farmer or veterinarian.

    Input details:
    - Classifier Function: {classifier_description}
    - Classifier Results: {classifier_outputs}
    - Cow ID: {cow_id}
    - Timestamp: {timestamp}
    - Disease Detected: {disease_detected}

    Expected Report Structure:

    1. Disease Name: {disease_detected}

    2. Brief Description:  
    Explain the disease using the classifier results ({classifier_outputs}) and logic behind the detection method ({classifier_description}).

    3. Causes of the Disease:  
    List the most probable causes relevant to this case, supported by general veterinary knowledge.

    4. Symptoms Observed:  
    Describe the typical visible symptoms or signs from the image that may have led to this classification.

    5. Is it Contagious?  
    State if the disease is transmissible to other animals, and how.

    6. Severity of the Disease:  
    Indicate the seriousness of the condition and risks if untreated.

    7. What Can the Farmer Do? (Initial Advice):  
    Immediate and practical steps the farmer should take, such as isolating the cow, improving hygiene, or monitoring symptoms.

    8. Does it Require Immediate Veterinary Attention?  
    Yes / No — provide guidance on the urgency of veterinary involvement.

    Format the report clearly and professionally, suitable for non-specialist farmers while being medically reliable for veterinary interpretation.
    
    Return the report as a JSON object with the following structure:

    {{
      "disease_name": "{disease_detected}",
      "description": "Brief explanation using classifier results and detection logic.",
      "causes": ["Cause 1", "Cause 2", "..."],
      "symptoms": ["Symptom 1", "Symptom 2", "..."],
      "is_contagious": "Yes/No - explanation",
      "severity": "Low/Moderate/High - explanation",
      "farmer_advice": "Practical steps the farmer should take immediately.",
      "needs_vet_attention": "Yes/No - explanation"
    }}
    
    Make sure the response is strictly formatted as valid JSON.
    Use concise and clear language appropriate for both farmers and veterinarians.
    """

    prompt = PromptTemplate(
        input_variables=[
            "classifier_description",
            "classifier_outputs",
            "cow_id",
            "timestamp",
            "disease_detected"
        ],
        template=template
    )

    chain = LLMChain(llm=llm, prompt=prompt)

    report = chain.run(
        classifier_description=classifier_description,
        classifier_outputs=classifier_outputs,
        cow_id=cow_id,
        timestamp=timestamp,
        disease_detected=disease_detected
    )
    cleaned = re.sub(r"^```json|```$" , "" , report.strip() , flags=re.MULTILINE).strip()
    parsed_report = json.loads(cleaned)

    return parsed_report
