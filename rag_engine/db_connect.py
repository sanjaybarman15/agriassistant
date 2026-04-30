import os
import psycopg2
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get DATABASE_URL from .env
DATABASE_URL = os.getenv("DIRECT_URL")

try:
    # Connect to PostgreSQL (Supabase)
    conn = psycopg2.connect(DATABASE_URL)

    # Create cursor to run SQL queries
    cursor = conn.cursor()

    # Simple test query
    cursor.execute("SELECT NOW();")

    # Fetch result
    result = cursor.fetchone()

    print("Successfully connected to Supabase PostgreSQL!")
    print("Current Database Time:", result)

    # Close connection
    cursor.close()
    conn.close()

except Exception as e:
    print("Database Connection Failed!")
    print("Error:", e)