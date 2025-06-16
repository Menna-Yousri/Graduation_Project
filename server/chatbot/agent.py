import os
import pandas as pd
import numpy as np
from typing import List
from pydantic.v1 import BaseModel, Field
import google.generativeai as genai
from dotenv import load_dotenv
# ✅ SET YOUR GEMINI API KEY
# Load environment variables
load_dotenv()

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-1.5-flash')

# ✅ File path (adjust if needed)
CSV_FILE = r"chatbot/farm_environment.csv"

def load_data():
    try:
        df = pd.read_csv(CSV_FILE)
        return {"farm_environment": df}
    except Exception as e:
        print(f"Error loading CSV file: {e}")
        return None

dfs = load_data()

class Table(BaseModel):
    name: str = Field(description="Name of table (CSV file) in dataset.")

def extract_categories(question: str) -> List[Table]:
    # Always return the single table "farm_environment"
    return [Table(name="farm_environment")]

def get_tables(categories: List[Table]) -> List[str]:
    # Always return the single table key
    return ["farm_environment"]

def generate_pandas_query(question: str, tables_to_use: List[str]) -> str:
    columns_info = ""
    if dfs is None:
        return "def get_answer(dfs):\n    return 'Data not loaded.'"
    for table in tables_to_use:
        if table in dfs:
            df = dfs[table]
            columns_info += f"\nTable '{table}' Columns:\n- " + "\n- ".join(df.columns) + "\n"
            for col in df.columns:
                values = df[col].dropna().astype(str).unique()[:3]
                columns_info += f"  → Examples from '{col}': {', '.join(values)}\n"
            columns_info += "\n"

    prompt = f"""
You are a smart Python assistant working with tabular farm data.

Your task is to write a Python function that answers the question:
"{question}"

Available DataFrames:
{columns_info}

Use DataFrame variable named dfs["farm_environment"] to access the data.
Your answer must:
- Identify relevant columns even if the names don’t match exactly.
- Use pandas to extract the full answer.
- Return all matching rows (if multiple).
- Return a short, user-friendly string answer.
- Handle errors gracefully (e.g., data not found).
- Avoid unnecessary explanation.

Return ONLY the function in this format:
```python
def get_answer(dfs):
    # your code
    return "your answer"
```
"""
    response = model.generate_content(prompt)
    return response.text.strip()

def clean_code(code: str) -> str:
    lines = code.strip().splitlines()
    cleaned_lines = [line for line in lines if not line.strip().startswith("```")]
    return "\n".join(cleaned_lines).strip()

def execute_pandas_query(code: str):
    try:
        local_namespace = {'dfs': dfs, 'pd': pd, 'np': np}
        exec(code, globals(), local_namespace)
        function_name = next((name for name in local_namespace if callable(local_namespace[name]) and name != 'pd' and name != 'np'), None)
        if function_name:
            return local_namespace[function_name](dfs)
        return "No answer function found."
    except Exception as e:
        return f"Error: {str(e)}"

def refine_answer_with_llm(question: str, raw_answer: str) -> str:
    prompt = f"""
You are a helpful assistant summarizing farm data answers.

Question: {question}
Raw answer (from data): {raw_answer}

Rephrase the answer clearly and briefly. If already clear, keep it.
"""
    try:
        response = model.generate_content(prompt)
        return response.text.strip()
    except Exception:
        return raw_answer

def get_answer(question: str) -> str:
    categories = extract_categories(question)
    tables_to_use = get_tables(categories)
    pandas_code = generate_pandas_query(question, tables_to_use)
    cleaned_code = clean_code(pandas_code)
    result = execute_pandas_query(cleaned_code)
    final_answer = refine_answer_with_llm(question, result)
    return final_answer

# ✅ Example
if __name__ == "__main__":
    question = "How many days that the temperature is higher than 25?"
    print(get_answer(question))