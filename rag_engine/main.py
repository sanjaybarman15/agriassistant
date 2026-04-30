from retriever import retrieve_relevant_chunks
from trigger_engine import should_trigger_fallback
from fallback_engine import get_fallback_response


def prepare_rag_context(retrieved_chunks):
    """
    Convert retrieved chunks into clean context
    for conversational LLM consumption
    """

    combined_context = "\n\n".join(
        [chunk["chunk_text"] for chunk in retrieved_chunks]
    )

    return combined_context[:3000]


def ask_question(user_query, domain="legal"):
    """
    Final production-ready RAG engine output

    Returns structured response for backend integration
    """

    # Step 1 — Retrieve chunks
    retrieved_chunks = retrieve_relevant_chunks(
        user_query=user_query,
        domain=domain,
        top_k=3
    )

    top_score = (
        retrieved_chunks[0]["similarity_score"]
        if retrieved_chunks else 0
    )

    # Step 2 — Fallback scoring
    fallback_result = get_fallback_response(user_query)

    fallback_score = fallback_result.get(
        "match_score",
        0
    )

    # Step 3 — Smart decision
    use_fallback = should_trigger_fallback(
        retrieved_chunks=retrieved_chunks,
        fallback_match_score=fallback_score,
        low_threshold=0.20,
        high_threshold=0.40
    )

    # Step 4 — Final structured output
    if use_fallback:
        return {
            "source": "fallback",
            "context": None,
            "fallback_answer": fallback_result,
            "metadata": {
                "top_score": top_score,
                "fallback_score": fallback_score
            }
        }

    rag_context = prepare_rag_context(
        retrieved_chunks
    )

    return {
        "source": "rag",
        "context": rag_context,
        "fallback_answer": None,
        "metadata": {
            "top_score": top_score,
            "fallback_score": fallback_score
        }
    }


if __name__ == "__main__":
    test_question = "Can the company terminate me without warning?"

    result = ask_question(test_question)

    print(result)