import os
from openai import OpenAI
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

class AdvisoryService:
    def __init__(self):
        # Initialize NVIDIA NIM (OpenAI compatible)
        api_key = os.getenv("NVIDIA_API_KEY")
        base_url = os.getenv("NVIDIA_BASE_URL", "https://integrate.api.nvidia.com/v1")
        
        if api_key:
            self.client = OpenAI(
                base_url=base_url,
                api_key=api_key
            )
            self.model = os.getenv("DEFAULT_CHAT_MODEL", "meta/llama-3.1-405b-instruct")
        else:
            self.client = None
            self.model = None
        
        # Initialize Supabase
        supabase_url = os.getenv("SUPABASE_URL")
        supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
        self.supabase: Client = create_client(supabase_url, supabase_key)

    async def get_advice(self, query: str, farmer_id: str, field_id: str = None, session_id: str = None):
        """
        Generates agricultural advice using NVIDIA NIM and manages chat history in Supabase.
        """
        if not self.client:
            return {"error": "NVIDIA API Key missing."}

        try:
            # 1. Create or verify chat session (Matching schema.sql)
            if not session_id:
                session_resp = self.supabase.table("chat_sessions").insert({
                    "farmer_id": farmer_id,
                    "field_id": field_id,
                    "language": "en"
                }).execute()
                session_id = session_resp.data[0]["id"]

            # 2. Save User Message
            self.supabase.table("chat_messages").insert({
                "session_id": session_id,
                "role": "user",
                "content": query
            }).execute()

            # 3. Generate AI Response with NVIDIA NIM
            system_prompt = (
                "You are AgriAssistant, an expert agricultural advisor for farmers in Assam, India. "
                "Provide practical, low-cost, and sustainable advice. "
                "Mention specific local crops like Tea, Rice, and Jute when relevant. "
                "Keep responses concise and helpful."
            )
            
            # Fetch previous messages for context
            history = self.supabase.table("chat_messages").select("role, content").eq("session_id", session_id).order("created_at").limit(5).execute()
            messages = [{"role": "system", "content": system_prompt}]
            for m in history.data:
                messages.append({"role": m["role"], "content": m["content"]})
            
            # Add current query
            messages.append({"role": "user", "content": query})

            completion = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                temperature=0.5,
                top_p=1,
                max_tokens=1024,
                stream=False
            )
            
            ai_text = completion.choices[0].message.content

            # 4. Save Assistant Message
            self.supabase.table("chat_messages").insert({
                "session_id": session_id,
                "role": "assistant",
                "content": ai_text
            }).execute()

            return {
                "session_id": session_id,
                "response": ai_text
            }

        except Exception as e:
            print(f"NVIDIA NIM Advisory Error: {str(e)}")
            return {"error": str(e)}
