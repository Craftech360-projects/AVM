import psycopg2
from psycopg2.extras import RealDictCursor
 # Import the task
# Database configuration
DB_CONFIG = {
    "dbname": "altio",  # Replace with your PostgreSQL database name
    "user": "your_username",        # Replace with your PostgreSQL username
    "password": "your_password",    # Replace with your PostgreSQL password
    "host": "localhost",            # Replace with your database host (e.g., "localhost" or an IP address)
    "port": 5432                    # Default PostgreSQL port
}

def get_db_connection():
    """Get a connection to the PostgreSQL database."""
    return psycopg2.connect(**DB_CONFIG)

def create_tasks_table():
    """Create the tasks table if it does not exist."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
            task_id UUID PRIMARY KEY,
            task_name VARCHAR(255),
            uid VARCHAR(255) NOT NULL,
            status VARCHAR(50) NOT NULL,
            result TEXT,
            error TEXT,
            created_at TIMESTAMP NOT NULL,
            updated_at TIMESTAMP NOT NULL
        );
    ''')
    conn.commit()
    conn.close()

# Call the function to create the table when the module is loaded
create_tasks_table()