import os
from docx import Document
from text_chunker import chunk_text

DOCS_FOLDER = "legal_corpus"


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


def process_all_documents():
    for filename in os.listdir(DOCS_FOLDER):
        if filename.endswith(".docx"):
            file_path = os.path.join(DOCS_FOLDER, filename)

            print(f"\nProcessing: {filename}")

            extracted_text = extract_text_from_docx(file_path)

            if extracted_text:
                chunks = chunk_text(extracted_text)

                print(f"\nTotal Chunks Created: {len(chunks)}\n")

                for i, chunk in enumerate(chunks[:3]):
                    print(f"Chunk {i+1} Preview:\n")
                    print(chunk[:500])
                    print("\n" + "=" * 100)


if __name__ == "__main__":
    process_all_documents()