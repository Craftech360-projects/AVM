from celery import Celery

celery_app = Celery('tasks',
                    broker='redis://redis:6379/0',  # Use service name instead of localhost
                    backend='redis://redis:6379/0',
                    include=['tasks']
)

# celery_app = Celery('tasks',
#                     broker='redis://localhost:6379/0',  # Use service name instead of localhost
#                     backend='redis://localhost:6379/0',
#                     include=['tasks']
# )
# Celery Configuration
celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    worker_max_memory_per_child=500000,  # Lower memory limit (500MB)
    worker_max_tasks_per_child=1,        # Restart worker after each task
    task_time_limit=900,                 # 15 minutes
    task_soft_time_limit=600,            # 10 minutes
    worker_concurrency=1                 # Single worker process
)

celery_app.conf.task_routes = {
    'tasks.process_audio': {'queue': 'audio_processing'}
}
