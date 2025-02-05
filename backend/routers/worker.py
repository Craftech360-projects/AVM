import sys
import os
from redis import Redis
from rq import Worker, Queue
from dotenv import load_dotenv
import logging

# Set up logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(levelname)s: %(message)s'
)
logger = logging.getLogger('rq.worker')

# Add the parent directory to Python path
parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(parent_dir)
print(f"Added to Python path: {parent_dir}")

# Load environment variables
load_dotenv()

# Create Redis connection
# redis_conn = Redis(
#     host='localhost', 
#     port=int(os.getenv('REDIS_DB_PORT')) if os.getenv('REDIS_DB_PORT') is not None else 6379,
#     username='default',
#     password=os.getenv('REDIS_DB_PASSWORD'),
#     ssl=True,
#     health_check_interval=30
# )
redis_conn = Redis(host='localhost', port=6379,)

def handle_exception(job, exc_type, exc_value, traceback):
    logger.error(f"Job {job.id} failed with {exc_type.__name__}: {exc_value}")
    return False  # Don't retry the job

def main():
    try:
        # Test Redis connection
        redis_conn.ping()
        print("Redis connection successful!")
        
        # Create the queue
        queue = Queue('audio_processing', connection=redis_conn)
        print(f"Listening to queue: {queue.name}")
        print(f"Current queue size: {len(queue)}")
        
        # Start the worker
        print("Starting worker...")
        worker = Worker(
            [queue], 
            connection=redis_conn,
            exception_handlers=[handle_exception]
        )
        print(f"Worker {worker.key} listening to queue: {queue.name}")
        
        # List available functions
        print("Python path:", sys.path)
        print("Current working directory:", os.getcwd())
        
        worker.work(logging_level=logging.DEBUG)
            
    except Exception as e:
        logger.error(f"Error starting worker: {e}", exc_info=True)
        raise

if __name__ == "__main__":
    main()