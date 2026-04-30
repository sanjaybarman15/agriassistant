import requests
import os
from dotenv import load_dotenv

load_dotenv()

NVIDIA_API_KEY = os.getenv("NVIDIA_API_KEY")


def get_embedding_nvidia(text: str, input_type: str = "passage"):
    """
    Generate embeddings using NVIDIA Build API

    input_type:
    - passage → for document chunks
    - query → for user questions
    """

    url = "https://integrate.api.nvidia.com/v1/embeddings"

    headers = {
        "Authorization": f"Bearer {NVIDIA_API_KEY}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    payload = {
        "model": "nvidia/llama-3.2-nemoretriever-300m-embed-v1",
        "input": [text],
        "input_type": input_type,
        "encoding_format": "float",
        "truncate": "END"
    }

    response = requests.post(
        url,
        headers=headers,
        json=payload,
        timeout=30
    )

    print(f"Status Code: {response.status_code}")

    if response.status_code != 200:
        print(f"Raw Response: {response.text[:500]}")

    response.raise_for_status()

    return response.json()["data"][0]["embedding"]