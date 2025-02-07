from celery_config import celery_app
import tasks  # This is important - it imports the tasks so they get registered
