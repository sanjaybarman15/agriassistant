def should_trigger_fallback(
    retrieved_chunks,
    fallback_match_score,
    low_threshold=0.20,
    high_threshold=0.40
):
    """
    Smart decision engine

    Logic:
    1. No chunks → fallback
    2. Very low score → fallback
    3. Very high score → RAG
    4. Medium score + strong fallback → fallback
    """

    if not retrieved_chunks:
        print("Fallback Triggered: No relevant chunks found")
        return True

    top_score = retrieved_chunks[0]["similarity_score"]

    print(f"Top Similarity Score: {top_score:.4f}")
    print(f"Fallback Match Score: {fallback_match_score}")

    # Very low confidence
    if top_score < low_threshold:
        print("Fallback Triggered: Very low retrieval confidence")
        return True

    # Very high confidence
    if top_score >= high_threshold:
        print("RAG Approved: Strong retrieval confidence")
        return False

    # Medium zone → compare fallback strength
    if fallback_match_score >= 5:
        print("Fallback Triggered: Medium RAG + Strong fallback match")
        return True

    print("RAG Approved: Medium RAG but fallback weak")
    return False