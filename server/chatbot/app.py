import os
import pandas as pd
import numpy as np
from typing import List
from pydantic.v1 import BaseModel, Field
import google.generativeai as genai
from dotenv import load_dotenv
from chatbot.rag import get_answer as rag_get_answer
#from panda import  get_pandas_answer
from chatbot.agent import get_answer as get_agent_answer
import json
import chatbot.web_farmer
import chatbot.web_vet
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel("gemini-1.5-flash")

# classify question type
def classify_question(question: str) -> str:
    prompt = f"""
You are a smart question classifier.

You must choose ONLY ONE of the following labels:
- pandas → for questions about structured tabular data, like cow records or farm environment data
- rag → for questions based on PDF documents, like diseases, symptoms, or treatments
- web → for general knowledge or online-related questions that are not covered by internal data

Think carefully.

Question: {question}
Answer (one word only):
"""
    response = model.generate_content(prompt)
    return response.text.strip().lower()


def get_smart_answer_farmer(question: str) -> str:
    query_type = classify_question(question)

    if query_type == "pandas":
        answer = get_agent_answer(question)
        return json.dumps({"answer": answer, "type": "Environment AGENT"})

    elif query_type == "rag":
        answer = rag_get_answer(question)
        return json.dumps({"answer": answer, "type": "RAG"})

    elif query_type == "web":
        answer = chatbot.web_farmer.run_web_search(question)
        return json.dumps({"answer": answer, "type": "WEB"})

    else:
        return json.dumps({"error": "Couldn't classify your question.", "type": None})

def get_smart_answer_vet(question: str) -> str:
    query_type = classify_question(question)

    if query_type == "pandas":
        answer = get_agent_answer(question)
        return json.dumps({"answer": answer, "type": "Environment AGENT"})

    elif query_type == "rag":
        answer = rag_get_answer(question)
        return json.dumps({"answer": answer, "type": "RAG"})

    elif query_type == "web":
        answer = chatbot.web_vet.run_web_search(question)
        return json.dumps({"answer": answer, "type": "WEB"})

    else:
        return json.dumps({"error": "Couldn't classify your question.", "type": None})