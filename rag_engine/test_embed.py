from embeddings import get_embedding_nvidia

if __name__ == "__main__":
    vec = get_embedding_nvidia(
        "This is a test legal clause about termination."
    )

    print(f"Embedding Dimension: {len(vec)}")