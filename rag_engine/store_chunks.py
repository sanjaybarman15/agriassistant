import os
import psycopg2
from dotenv import load_dotenv
from docx import Document
from embeddings import get_embedding_nvidia
from text_chunker import chunk_text

load_dotenv()

DATABASE_URL = os.getenv("DIRECT_URL")
DOCS_FOLDER = "legal_corpus"
DOMAIN = "legal"


def extract_text_from_docx(file_path):
    try:
        doc = Document(file_path)
        full_text = []

        for para in doc.paragraphs:
            text = para.text.strip()

            if text:
                full_text.append(text)

        return "\n".join(full_text)

    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None


def insert_chunk(cursor, domain, source_file, chunk_text, embedding):
    cursor.execute("""
        INSERT INTO document_chunks
        (domain, source_file, chunk_text, embedding)
        VALUES (%s, %s, %s, %s)
    """, (
        domain,
        source_file,
        chunk_text,
        embedding
    ))


def process_documents():
    conn = psycopg2.connect(DATABASE_URL)
    cursor = conn.cursor()

    for filename in os.listdir(DOCS_FOLDER):
        if filename.endswith(".docx"):
            file_path = os.path.join(DOCS_FOLDER, filename)

            print(f"\nProcessing: {filename}")

            extracted_text = extract_text_from_docx(file_path)

            if not extracted_text:
                continue

            chunks = chunk_text(extracted_text)

            print(f"Total Chunks: {len(chunks)}")

            for i, chunk in enumerate(chunks):
                print(f"Embedding chunk {i+1}/{len(chunks)}...")

                try:
                    embedding = get_embedding_nvidia(
                        chunk,
                        input_type="passage"
                    )

                    insert_chunk(
                        cursor,
                        DOMAIN,
                        filename,
                        chunk,
                        embedding
                    )

                    conn.commit()

                except Exception as e:
                    print(f"Failed on chunk {i+1}: {e}")

    cursor.close()
    conn.close()

    print("\nAll chunks stored successfully!")


if __name__ == "__main__":
    process_documents()