import os
from .database import get_db_connection
from redis import Redis
from rq import Queue
from dotenv import load_dotenv
import time
from dotenv import load_dotenv
# Load environment variables from .env file
load_dotenv()

# print(os.getenv('REDIS_DB_HOST'))
# print(os.getenv('REDIS_DB_PORT'))
# print(os.getenv('REDIS_DB_PASSWORD'))

# redis_conn = Redis(
#     host=os.getenv('REDIS_DB_HOST'), 
#     port=int(os.getenv('REDIS_DB_PORT')) ,
#     username='default',
#     password=os.getenv('REDIS_DB_PASSWORD'),
#     ssl=True,  # Enable SSL for Upstash Redis
#     health_check_interval=30
# )
redis_conn = Redis(host='localhost', port=6379) 

try:
    redis_conn.ping()  # Test the connection
    print("Upstash Redis connection successful!")
except Exception as e:
    print(f"Upstash Redis connection failed: {e}")

# Optionally, you can also initialize the RQ queue here if you're using it for background tasks
print("Redis connection imported successfully:", redis_conn)

task_queue = Queue('audio_processing', connection=redis_conn)
print("Task queue imported successfully:", task_queue)

# Clear all jobs and tasks before starting the test
def clear_all_jobs_and_tasks():
    print("Clearing all jobs and tasks...")
    task_queue.empty()

    # Manually delete jobs from the queue
    for job_id in task_queue.job_ids:
        job = task_queue.fetch_job(job_id)
        if job:
            job.delete()

    print("All jobs and tasks cleared.")

# Test basic Redis operations
def test_redis_operations():
    try:
        # Test setting a key-value pair
        redis_conn.set("test_key", "Hello, Redis!")
        print("Set key 'test_key' successfully.")

        # Test retrieving the value
        value = redis_conn.get("test_key")
        print(f"Retrieved value: {value.decode() if value else 'None'}")

        # Test deleting the key
        redis_conn.delete("test_key")
        print("Deleted key 'test_key'.")

        print("Redis operations test completed successfully!")
    except Exception as e:
        print(f"Redis operations test failed: {e}")

# At the module level, before any functions
# At the module level
def example_task(x, y):
    try:
        print(f"Executing example_task with arguments: {x}, {y}")
        result = x + y
        print(f"Task result: {result}")
        return result
    except Exception as e:
        print(f"Task failed with error: {e}")
        raise

def test_worker_and_queue():
    try:
        # Enqueue a test task with explicit function reference
        job = task_queue.enqueue(
            example_task,
            args=(1, 2),
            timeout=30,
            job_timeout=360,  # Longer timeout
            result_ttl=500    # Keep result longer
        )
        print(f"Enqueued job: {job.id}")
        print(f"Current queue size: {len(task_queue)}")
        print(f"Queue name: {task_queue.name}")

        # Wait for the job to be processed
        max_wait = 30
        start_time = time.time()
        
        while not job.is_finished and not job.is_failed:
            status = job.get_status()
            print(f"Job status: {status}")
            if status == "failed":
                exc_info = job.exc_info
                print(f"Job failed with error: {exc_info}")
                break
                
            print(f"Queue length: {len(task_queue)}")
            
            if time.time() - start_time > max_wait:
                print("Timeout waiting for job completion")
                break
                
            time.sleep(1)

        if job.is_finished:
            print(f"Job completed with result: {job.result}")
        elif job.is_failed:
            print(f"Job failed with error: {job.exc_info}")
        else:
            print("Job not completed. Current status:", job.get_status())
            
    except Exception as e:
        print(f"Worker and queue test failed: {e}")
        raise
# Export the Redis connection and task queue so they can be used elsewhere in the application
__all__ = ['get_db_connection', 'redis_conn', 'task_queue']

# clear_all_jobs_and_tasks()
# test_redis_operations()
# test_worker_and_queue()