def initialize_knowledge_base(pdf_dir: str, index_name: str = "moonetbot"):
    """
    Preprocess PDF files and upload embeddings to Pinecone with improved chunking and metadata.
    Run this ONCE.
    """
    import os
    from dotenv import load_dotenv
    from langchain.document_loaders import PyPDFLoader, DirectoryLoader
    from langchain.text_splitter import RecursiveCharacterTextSplitter
    from langchain_google_genai import GoogleGenerativeAIEmbeddings
    import google.generativeai as genai
    from pinecone.grpc import PineconeGRPC as Pinecone
    from pinecone import ServerlessSpec
    from langchain_pinecone import PineconeVectorStore

    load_dotenv()
    genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

    # Load PDF documents
    loader = DirectoryLoader(pdf_dir, glob="*.pdf", loader_cls= PyPDFLoader)
    documents = loader.load()

    # Add page metadata if missing
    for doc in documents:
        if "page" not in doc.metadata:
            doc.metadata["page"] = doc.metadata.get("source", "").split("-")[-1].replace(".txt", "")

    # Improved chunking
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=1200,
        chunk_overlap=200,
        separators=["\n\n", "\n", ".", " ", ""]
    )
    chunks = splitter.split_documents(documents)

    # Embeddings
    embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")

    # Pinecone setup
    pc = Pinecone(api_key=os.getenv("PINECONE_API_KEY"))
    if index_name in pc.list_indexes().names():
        pc.delete_index(index_name)

    pc.create_index(
        name=index_name,
        dimension=768,
        metric="cosine",
        spec=ServerlessSpec(cloud="aws", region="us-east-1")
    )

    # Upload chunks
    batch_size = 50
    for i in range(0, len(chunks), batch_size):
        batch = chunks[i:i + batch_size]
        PineconeVectorStore.from_documents(
            documents=batch,
            index_name=index_name,
            embedding=embeddings
        )

    print(f"Knowledge base initialized with {len(chunks)} chunks.")

def get_answer(question: str, index_name: str = "moonetbot"):
    """
    Retrieve the best answer to a user query using Pinecone and Gemini 2.0 LLM.
    """
    import os
    from dotenv import load_dotenv
    from langchain_google_genai import GoogleGenerativeAIEmbeddings, ChatGoogleGenerativeAI
    from langchain_pinecone import PineconeVectorStore
    from langchain_core.prompts import ChatPromptTemplate
    from langchain.chains.combine_documents import create_stuff_documents_chain
    import google.generativeai as genai

    load_dotenv()
    genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

    # Load vector store
    embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
    vector_store = PineconeVectorStore.from_existing_index(index_name=index_name, embedding=embeddings)

    # Retrieve documents
    results = vector_store.similarity_search_with_score(question, k=30)
    filtered_docs = [doc for doc, score in results if score >= 0.65 and hasattr(doc, "page_content")]
    sources = [doc.metadata.get("source", None) for doc in filtered_docs]

    # General-purpose prompt
    system_prompt = (
        "You are an expert assistant helping users extract accurate and comprehensive information from the provided context.\n"
        "- Use only the given context to answer the question.\n"
        "- If the context does not contain the answer, reply: 'The document does not contain this information.'\n"
        "- Do not speculate or invent information.\n\n"
        "Format the response in **Markdown**, using:\n"
        "- Headings (##)\n"
        "- Bullet points\n"
        "- **Bold** for key terms or data points\n"
        "- Reference page numbers or sections if available.\n\n"
        "CONTEXT:\n{context}"
    )

    prompt = ChatPromptTemplate.from_messages([
        ("system", system_prompt),
        ("human", "{input}")
    ])

    llm = ChatGoogleGenerativeAI(
        model="gemini-2.0-flash-exp",
        temperature=0.4,
        max_output_tokens=1024
    )

    qa_chain = create_stuff_documents_chain(llm, prompt)
    response = qa_chain.invoke({"input": question, "context": filtered_docs})

    # Combine response with sources in one string
    unique_sources = sorted(set(filter(None, sources)))
    sources_str = "\n".join([f"- {src}" for src in unique_sources]) if unique_sources else "- No sources found."

    full_output = f"{response}\n\n---\n\n📚 **Sources:**\n{sources_str}"

    return full_output

# Only once to initialize
# initialize_knowledge_base(pdf_dir="/content")

# Get the answer
# answer, sources = get_answer("What is the treatment for mastitis?")
# print("Answer:\n", answer)

# print("\n📚 Sources:")
# for src in sources:
#    print(f"- {src}")