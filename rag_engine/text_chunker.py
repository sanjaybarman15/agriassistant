def chunk_text(text, chunk_size=1200):
    """
    Paragraph-aware chunking for legal documents
    Keeps clauses more meaningful
    """

    paragraphs = text.split("\n")
    chunks = []
    current_chunk = ""

    for para in paragraphs:
        para = para.strip()

        if not para:
            continue

        # if adding this paragraph exceeds size
        if len(current_chunk) + len(para) < chunk_size:
            current_chunk += para + "\n"
        else:
            chunks.append(current_chunk.strip())
            current_chunk = para + "\n"

    if current_chunk:
        chunks.append(current_chunk.strip())

    return chunks


if __name__ == "__main__":
    sample_text = """
    Clause 1: Payment Terms

    The employee shall receive salary on the last working day of each month.

    Clause 2: Notice Period

    The employee must provide 30 days written notice before resignation.
    """

    result = chunk_text(sample_text)

    print(f"Total Chunks Created: {len(result)}\n")

    for i, chunk in enumerate(result):
        print(f"Chunk {i+1}:\n")
        print(chunk)
        print("\n" + "=" * 80)