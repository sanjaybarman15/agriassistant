import json
import os


BASE_DIR = os.path.dirname(os.path.abspath(__file__))

FALLBACK_FILE = os.path.join(
    BASE_DIR,
    "fallback_data",
    "legal_fallback.json"
)


def load_fallback_data():
    """
    Load fallback corpus JSON
    """

    try:
        with open(FALLBACK_FILE, "r", encoding="utf-8") as file:
            data = json.load(file)

        print(f"Loaded {len(data)} fallback records successfully.")
        return data

    except Exception as e:
        print(f"Error loading fallback corpus: {str(e)}")
        return []


def calculate_match_score(user_query, record):
    """
    Better scoring with:
    - keyword normalization
    - synonym support
    - topic match
    - document type match
    - user question overlap
    """

    query = user_query.lower()

    # Simple synonym normalization
    synonym_map = {
        "resigning": "resignation",
        "resign": "resignation",
        "quit": "resignation",
        "fired": "termination",
        "fire": "termination",
        "warning": "termination",
        "salary": "payment",
        "pay": "payment",
        "money": "payment",
        "secret": "confidentiality",
        "nda": "confidentiality",
        "red flags": "risk",
        "risky": "risk",
        "dangerous": "risk"
    }

    for word, replacement in synonym_map.items():
        query = query.replace(word, replacement)

    score = 0
    # Topic match
    topic_text = record["topic"].replace("_", " ").lower()

    if topic_text in query:
        score += 5

    # Document type match
    document_type = record["document_type"].replace("_", " ").lower()

    if document_type in query:
        score += 4

    # User question similarity
    for question in record.get("user_questions", []):
        question = question.lower()

        common_words = set(query.split()) & set(question.split())

        if len(common_words) >= 2:
            score += 2

    return score


def get_fallback_response(user_query):
    """
    Returns:
    - best fallback response
    - fallback match score

    Used by trigger engine to decide:
    RAG vs fallback
    """

    fallback_data = load_fallback_data()

    if not fallback_data:
        return {
            "source": "fallback",
            "topic": "system_error",
            "document_type": "general",
            "answer": "Fallback knowledge base is currently unavailable.",
            "red_flags": [
                "System could not load fallback data"
            ],
            "practical_advice": [],
            "negotiation_tips": [],
            "risk_level": "unknown",
            "match_score": 0
        }

    best_match = None
    best_score = -1

    # Find strongest matching record
    for record in fallback_data:
        score = calculate_match_score(user_query, record)

        if score > best_score:
            best_score = score
            best_match = record

    # No meaningful match found
    if best_score <= 0:
        return {
            "source": "fallback",
            "topic": "general_legal_review",
            "document_type": "general",
            "answer": (
                "Before signing any legal agreement, carefully review notice periods, "
                "termination conditions, payment obligations, liability, penalties, "
                "and dispute resolution clauses."
            ),
            "red_flags": [
                "Hidden penalties",
                "Unclear responsibilities",
                "Missing dispute resolution",
                "One-sided obligations"
            ],
            "practical_advice": [
                "Read termination and notice clauses carefully",
                "Check refund/payment obligations",
                "Confirm dispute resolution process"
            ],
            "negotiation_tips": [
                "Avoid vague obligations",
                "Ask for written protections",
                "Reduce one-sided clauses"
            ],
            "risk_level": "medium",
            "match_score": 0
        }

    return {
        "source": "fallback",
        "topic": best_match["topic"],
        "document_type": best_match["document_type"],
        "answer": best_match["simple_answer"],
        "red_flags": best_match.get("red_flags", []),
        "practical_advice": best_match.get("practical_advice", []),
        "negotiation_tips": best_match.get("negotiation_tips", []),
        "risk_level": best_match.get("risk_level", "medium"),
        "match_score": best_score
    }


if __name__ == "__main__":
    test_question = "What are the major red flags in this agreement?"

    result = get_fallback_response(test_question)

    print("\nFallback Response:\n")

    print("Topic:", result.get("topic"))
    print("Document Type:", result.get("document_type"))
    print("Match Score:", result.get("match_score"))
    print("Risk Level:", result.get("risk_level"))

    print("\nAnswer:")
    print(result.get("answer"))

    print("\nRed Flags:")
    for item in result.get("red_flags", []):
        print("-", item)

    print("\nPractical Advice:")
    for item in result.get("practical_advice", []):
        print("-", item)

    print("\nNegotiation Tips:")
    for item in result.get("negotiation_tips", []):
        print("-", item)