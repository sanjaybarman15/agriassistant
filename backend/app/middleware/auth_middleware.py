from fastapi import Request, HTTPException, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.db.supabase import supabase
from typing import Optional

security = HTTPBearer(auto_error=False)

class AuthUser:
    def __init__(self, id: str, email: str, is_guest: bool = False):
        self.id = id
        self.email = email
        self.is_guest = is_guest

async def get_current_user(
    request: Request,
    auth: Optional[HTTPAuthorizationCredentials] = Security(security)
) -> AuthUser:
    # 1. Try JWT Auth (Protected Routes)
    if auth:
        try:
            # Verify JWT with Supabase
            user_response = supabase.auth.get_user(auth.credentials)
            if user_response and user_response.user:
                return AuthUser(
                    id=user_response.user.id,
                    email=user_response.user.email,
                    is_guest=False
                )
        except Exception:
            pass

    # 2. Try Guest Auth (X-Guest-Session-Id header)
    guest_id = request.headers.get("X-Guest-Session-Id")
    if guest_id:
        return AuthUser(
            id=guest_id,
            email=f"guest_{guest_id[:8]}@aura.local",
            is_guest=True
        )

    # 3. Fallback: Anonymous user (allows initial load)
    return AuthUser(
        id="anonymous",
        email="anonymous@aura.local",
        is_guest=True
    )
