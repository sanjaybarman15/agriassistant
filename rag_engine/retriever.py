import os
import psycopg2
from dotenv import load_dotenv
from embeddings import get_embedding_nvidia

load_dotenv()

DATABASE_URL = os.getenv("DIRECT_URL")


def retrieve_relevant_chunks(user_query, domain="legal", top_k=3):
    """
    Retrieves top relevant chunks from pgvector
    based on cosine similarity
    """

    try:
        # Step 1: Generate query embedding
        print("Generating query embedding...")

        query_embedding = get_embedding_nvidia(
            user_query,
            input_type="query"
        )

        if not query_embedding:
            print("Failed to generate query embedding.")
            return []

        # Step 2: Connect to Supabase PostgreSQL
        conn = psycopg2.connect(DATABASE_URL)
        cursor = conn.cursor()

        print("Searching relevant chunks...")

        # Step 3: Vector similarity search
        cursor.execute("""
            SELECT
                id,
                source_file,
                chunk_text,
                1 - (embedding <=> %s::vector) AS similarity_score
            FROM document_chunks
            WHERE domain = %s
            ORDER BY embedding <=> %s::vector
            LIMIT %s;
        """, (
            query_embedding,
            domain,
            query_embedding,
            top_k
        ))

        results = cursor.fetchall()

        cursor.close()
        conn.close()

        formatted_results = []

        for row in results:
            formatted_results.append({
                "id": row[0],
                "source_file": row[1],
                "chunk_text": row[2],
                "similarity_score": float(row[3])
            })

        return formatted_results

    except Exception as e:
        print("Retriever Error:", str(e))
        return []


if __name__ == "__main__":
    test_question = "What is the notice period for resignation?"

    results = retrieve_relevant_chunks(test_question)

    print("\nTop Retrieved Chunks:\n")

    for i, item in enumerate(results):
        print(f"Result {i+1}")
        print(f"Source File: {item['source_file']}")
        print(f"Similarity Score: {item['similarity_score']:.4f}")
        print(f"Chunk Preview:\n{item['chunk_text'][:700]}")
        print("\n" + "=" * 100)