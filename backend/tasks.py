import logging
import os
import gc
import asyncio
import aiohttp
from celery_config import celery_app
from datetime import datetime
import json
from database import get_db_connection
import torch
# from utils.stt.whisperx import process_all_audio_files as whisperx_pipeline

# Configure logging
logging.basicConfig(level=logging.DEBUG,
                   format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

async def process_with_deepgram(audio_file, api_key):
    """Process a single audio file with Deepgram"""
    try:
        headers = {
            "Authorization": f"Token {api_key}",
            'Content-Type': 'audio/wav'
        }
        params = {
            'smart_format': 'true',
            'diarize': 'true',
            'punctuate': 'true',
            'utterances': 'true',
            'model': 'nova-2',
            'language': 'en'
        }
        
        async with aiohttp.ClientSession() as session:
            with open(audio_file, 'rb') as audio:
                async with session.post(
                    "https://api.deepgram.com/v1/listen",
                    headers=headers,
                    params=params,
                    data=audio
                ) as response:
                    if response.status != 200:
                        logger.error(f"Deepgram API error: {response.status}")
                        return None
                    result = await response.json()
                    return result
    except Exception as e:
        logger.error(f"Error processing file {audio_file}: {str(e)}")
        return None

def process_audio_files(user_dir, pipeline):
    """Process audio files with either whisperx or deepgram"""
    processed_files = []  # Initialize empty list at the start
    
    try:
        # Check if directory exists
        if not os.path.exists(user_dir):
            logger.error(f"Directory not found: {user_dir}")
            return [], []

        # Get list of audio files
        audio_files = [
            f for f in os.listdir(user_dir) 
            if f.endswith(('.wav', '.mp3'))
        ]
        
        if not audio_files:
            logger.error(f"No audio files found in {user_dir}")
            return [], []

        if pipeline == "deepgram":
            # ... existing deepgram code ...
            api_key = os.getenv('DEEPGRAM_API_KEY')
            if not api_key:
                logger.error("DEEPGRAM_API_KEY not found in environment")
                return [], []

            # Track processed files
            processed_files = [os.path.join(user_dir, f) for f in audio_files]
            
            # Process with Deepgram
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            try:
                tasks = [
                    process_with_deepgram(os.path.join(user_dir, f), api_key) 
                    for f in audio_files
                ]
                results = loop.run_until_complete(asyncio.gather(*tasks))
                
                # Convert results to our format
                transcripts = []
                for result in results:
                    if result and 'results' in result and 'utterances' in result['results']:
                        for utterance in result['results']['utterances']:
                            transcripts.append({
                                "text": utterance['transcript'],
                                "speaker": f"speaker_{utterance['speaker']}",
                                "start": utterance['start'],
                                "end": utterance['end']
                            })
                return transcripts, processed_files
            finally:
                loop.close()
        # else:
        #     # Process with whisperx
        #     processed_files = [os.path.join(user_dir, f) for f in audio_files]
        #     return whisperx_pipeline(directory=user_dir), processed_files

    except Exception as e:
        logger.error(f"Error in audio processing: {str(e)}")
        return [], processed_files  # Return empty transcripts but still return processed files

@celery_app.task(
    name='tasks.process_audio',
    bind=True,
    max_retries=3,
    acks_late=True,
    soft_time_limit=600,
    time_limit=900
)
def process_audio_task(self, task_id, uid, user_dir, pipeline="whisperx"):
    logger.info(f"Starting task {task_id} for user {uid} using {pipeline}")
    
    conn = None
    cursor = None
    processed_files = []  # Initialize empty list
    
    try:
        # Process audio files and get list of processed files
        combined_transcripts, processed_files = process_audio_files(user_dir, pipeline)
        
        if not combined_transcripts:
            raise ValueError("No transcripts generated")

        # Save results
        output_dir = os.path.join("transcripts", uid)
        os.makedirs(output_dir, exist_ok=True)
        output_file = os.path.join(output_dir, f"{task_id}_transcript.json")
        
        with open(output_file, 'w') as f:
            json.dump(combined_transcripts, f, indent=2)
            
        # Update database
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            UPDATE tasks
            SET status = %s, result = %s, updated_at = %s
            WHERE task_id = %s
        ''', ("completed", json.dumps(combined_transcripts), datetime.now(), task_id))
        conn.commit()
        
        logger.info(f"Task {task_id} completed successfully")
        return {
            "status": "completed", 
            "task_id": task_id,
            "transcript": combined_transcripts
        }
            
    except Exception as e:
        logger.error(f"Task failed: {str(e)}", exc_info=True)
        if cursor and conn:
            try:
                cursor.execute('''
                    UPDATE tasks
                    SET status = %s, error = %s, updated_at = %s
                    WHERE task_id = %s
                ''', ("failed", str(e), datetime.now(), task_id))
                conn.commit()
            except Exception as db_error:
                logger.error(f"Failed to update task status: {str(db_error)}")
        
        raise self.retry(exc=e, countdown=60)
        
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
        # Cleanup only the files that were processed
        for file_path in processed_files:
            try:
                if os.path.exists(file_path):
                    os.remove(file_path)
                    logger.debug(f"Cleaned up processed file: {file_path}")
            except Exception as e:
                logger.error(f"Error removing file {file_path}: {str(e)}")
        
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
