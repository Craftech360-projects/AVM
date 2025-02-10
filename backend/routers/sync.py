import os
import struct
import threading
import time
import json

import os
import torch
import whisperx
import json
from utils.endpoints import timeit
from dotenv import load_dotenv
from speechbrain.pretrained import SpeakerRecognition
from pyannote.audio import Audio
import numpy as np
from utils.speaker_profile import classify_segments
from datetime import datetime
from typing import List
import uuid
from fastapi import APIRouter, Header, UploadFile, File, Depends, HTTPException, Query
from opuslib import Decoder
from pydub import AudioSegment
from concurrent.futures import ThreadPoolExecutor
from database.memories import get_closest_memory_to_timestamps, update_memory_segments
from models.memory import CreateMemory
from models.transcript_segment import TranscriptSegment
from utils.memories.process_memory import process_memory
from utils.other import endpoints as auth
from utils.other.storage import get_syncing_file_temporal_signed_url, delete_syncing_temporal_file
from utils.stt.pre_recorded import fal_whisperx, fal_postprocessing
from utils.stt.vad import vad_is_empty
from utils.stt.whisperx import process_all_audio_files as whisperx_pipeline
from database import get_db_connection
router = APIRouter()
import shutil
import wave
import aiohttp
import asyncio
from speechbrain.pretrained import SpeakerRecognition
from pyannote.audio import Audio
import numpy as np

# Load SpeechBrain speaker recognition model
verification_model = SpeakerRecognition.from_hparams(
    source="speechbrain/spkrec-ecapa-voxceleb",
    savedir="pretrained_models/spkrec-ecapa-voxceleb"
)

# Path to the folder containing sample audio files for enrollment
sample_folder = "sample"
# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv()

DEEPGRAM_API_KEY = os.getenv('DEEPGRAM_API_KEY')
DEEPGRAM_API_URL = "https://api.deepgram.com/v1/listen"

# Thread pool for background tasks
executor = ThreadPoolExecutor(max_workers=4)
speaker_embeddings = {}
for enrollment_audio in os.listdir(sample_folder):
    enrollment_audio_path = os.path.join(sample_folder, enrollment_audio)
    signal = verification_model.load_audio(enrollment_audio_path)
    embedding = verification_model.encode_batch(signal.unsqueeze(0)).squeeze().cpu().numpy()
    speaker_embeddings[enrollment_audio] = embedding  # Use filename as key

def map_speakers_to_names(audio_file, transcript):
    """Map Deepgram speaker labels (e.g., speaker_0) to actual names using SpeechBrain."""
    audio_loader = Audio(sample_rate=16000)
    waveform, _ = audio_loader(audio_file)
    if waveform.ndim == 2 and waveform.shape[0] == 1:
        waveform = waveform.squeeze(0)

    # Dictionary to store mappings from speaker_X to actual names
    speaker_mapping = {}

    for segment in transcript:
        # Debug: Print segment structure
        print(f"Segment: {segment}")

        # Check if 'speaker' key exists
        if 'speaker' not in segment:
            print("Warning: 'speaker' key not found in segment. Skipping...")
            continue

        speaker_label = segment['speaker']
        start_time = segment['start']
        end_time = segment['end']

        # Skip if this speaker_X has already been mapped
        if speaker_label in speaker_mapping:
            segment['speaker'] = speaker_mapping[speaker_label]
            continue

        # Extract the audio segment corresponding to this speaker_X
        segment_audio = waveform[int(start_time * 16000):int(end_time * 16000)]
        if segment_audio.size == 0:
            speaker_mapping[speaker_label] = speaker_label  # Retain original label if no audio
            segment['speaker'] = speaker_label
            continue

        # Generate embedding for the segment
        segment_tensor = torch.tensor(segment_audio).unsqueeze(0)
        segment_embedding = verification_model.encode_batch(segment_tensor).squeeze().cpu().numpy()
        if segment_embedding.ndim == 2:
            segment_embedding = segment_embedding.squeeze()

        # Compare with pre-enrolled speaker embeddings
        best_match = None
        best_score = -np.inf
        for speaker_name, speaker_embedding in speaker_embeddings.items():
            if speaker_embedding.ndim == 2:
                speaker_embedding = speaker_embedding.squeeze()
            # Normalize embeddings
            segment_embedding_norm = segment_embedding / np.linalg.norm(segment_embedding)
            speaker_embedding_norm = speaker_embedding / np.linalg.norm(speaker_embedding)
            score = float(np.dot(segment_embedding_norm, speaker_embedding_norm))
            print(f"Segment [{start_time:.2f} - {end_time:.2f}] -> {speaker_name.split('.')[0]} (Score: {score:.4f})")
            if score > best_score:
                best_score = score
                best_match = speaker_name

        # Assign name or retain original label
        if best_score >= 0.6:  # Threshold for matching
            speaker_mapping[speaker_label] = best_match.split(".")[0]
        else:
            speaker_mapping[speaker_label] = speaker_label  # Retain original label

        # Update the segment's speaker label
        segment['speaker'] = speaker_mapping[speaker_label]

    print('Speaker mapping completed')
    return transcript

import json
import os

def save_individual_transcript(transcript, output_dir, file_name):
    """
    Save the transcript of an individual file as a JSON file.
    
    Args:
        transcript (list): List of transcript segments with 'start', 'end', 'text', and 'speaker' keys.
        output_dir (str): Directory where the JSON file will be saved.
        file_name (str): Name of the file (without extension) to use in the JSON file name.
    """
    os.makedirs(output_dir, exist_ok=True)  # Ensure the output directory exists
    file_path = os.path.join(output_dir, f"{file_name}_transcript.json")
    with open(file_path, "w") as f:
        json.dump(transcript, f, indent=4)
    print(f"Individual transcript saved to {file_path}")

def save_transcript_as_json(transcript, output_dir, task_id):
    """
    Save the transcript as a JSON file.
    
    Args:
        transcript (list): List of transcript segments with 'start', 'end', 'text', and 'speaker' keys.
        output_dir (str): Directory where the JSON file will be saved.
        task_id (str): Unique identifier for the task, used in the filename.
    """
    os.makedirs(output_dir, exist_ok=True)  # Ensure the output directory exists
    file_path = os.path.join(output_dir, f"{task_id}_transcript.json")
    with open(file_path, "w") as f:
        json.dump(transcript, f, indent=4)
    print(f"Transcript saved to {file_path}");
async def process_with_deepgram(audio_file):
    """Process audio file using Deepgram API"""
    print(f"Processing file: {audio_file}")
    headers = {
        "Authorization": f"Token {DEEPGRAM_API_KEY}",
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
    try:
        async with aiohttp.ClientSession() as session:
            with open(audio_file, 'rb') as audio:
                async with session.post(
                    DEEPGRAM_API_URL,
                    headers=headers,
                    params=params,
                    data=audio
                ) as response:
                    if response.status != 200:
                        raise Exception(f"Deepgram API error: {response.status}")
                    result = await response.json()
                    print(f"Received result for {audio_file}: {result}")
                    
                    # Convert Deepgram format to our format
                    transcript = []
                    for utterance in result['results']['utterances']:
                        segment = {
                            "text": utterance['transcript'],
                            "speaker": f"speaker_{utterance['speaker']}",
                            "start": utterance['start'],
                            "end": utterance['end']
                        }
                        transcript.append(segment)
                    return transcript
    except Exception as e:
        print(f"Error in Deepgram transcription for {audio_file}: {str(e)}")
        return []


def cleanup_audio_files(directory):
    """
    Delete all .wav and .mp3 files from the specified directory.
    
    Args:
        directory (str): Path to the directory containing audio files.
    """
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if filename.endswith(('.wav', '.mp3')) and os.path.isfile(file_path):
            try:
                os.remove(file_path)
                print(f"Deleted file: {file_path}")
            except Exception as e:
                print(f"Error deleting file {file_path}: {str(e)}")

def process_in_background(task_id, uid, user_dir, pipeline="whisperx"):
    print(f"Task {task_id} started processing using {pipeline} pipeline.")
    conn = get_db_connection()
    cursor = conn.cursor()
    try:
        combined_transcripts = []
        
        if pipeline == "deepgram":
            # Create event loop for async operations
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            audio_files = [
                os.path.join(user_dir, f) 
                for f in os.listdir(user_dir) 
                if f.endswith(('.wav', '.mp3'))
            ]
            
            async def process_all():
              tasks = [process_with_deepgram(audio_file) for audio_file in audio_files]
              results = await asyncio.gather(*tasks)
              # Filter out empty results
              filtered_results = [result for result in results if result]
              # Log results for debugging
              for i, result in enumerate(filtered_results):
               print(f"Filtered result for file {i + 1}: {result}")
              return [item for sublist in filtered_results for item in sublist]
            
            combined_transcripts = loop.run_until_complete(process_all())
            loop.close()
            # combined_transcripts = merge_segments(combined_transcripts, max_gap=120)
        else:
            combined_transcripts = whisperx_pipeline(directory=user_dir)

        # Save the final transcript as a JSON file
        output_dir = os.path.join("transcripts", uid)
        save_transcript_as_json(combined_transcripts, output_dir, task_id)

        # Update task status to "completed" and save the result
        cursor.execute('''
            UPDATE tasks
            SET status = %s, result = %s, updated_at = %s
            WHERE task_id = %s
        ''', ("completed", json.dumps(combined_transcripts), datetime.now(), task_id))
        conn.commit()
        print(f"Task {task_id} completed successfully using {pipeline} pipeline.")
        cleanup_audio_files(user_dir)

    except Exception as e:
        print(f"Task {task_id} failed: {str(e)}")
        cursor.execute('''
            UPDATE tasks
            SET status = %s, error = %s, updated_at = %s
            WHERE task_id = %s
        ''', ("failed", str(e), datetime.now(), task_id))
        conn.commit()
    finally:
        conn.close()

        update_memory_segments(uid, closest_memory['id'], segments)

@router.post("/v1/sync-local-files")
async def sync_local_files(
    files: List[UploadFile] = File(...), 
    uid: str = Header(None),
    pipeline: str = Query("whisperx", enum=["whisperx", "deepgram"])  # This enables pipeline selection
):
    if not uid:
        raise HTTPException(status_code=400, detail="Missing uid header")

    print("User ID:", uid)
    
    user_dir = f"syncing/{uid}/"
    os.makedirs(user_dir, exist_ok=True)
    paths = []

    
    # Save uploaded files to the user's directory
    bin_paths = []
    for file in files:
        file_path = os.path.join(user_dir, file.filename)
        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())
        bin_paths.append(file_path)


    print(f"Files saved to {user_dir}: {[os.path.basename(p) for p in paths]}")
        # Decode .bin files to .wav format
    try:
        wav_paths = decode_files_to_wav(bin_paths)
    except HTTPException as e:
        raise e  # Propagate the error to the client

    print(f"Decoded files: {[os.path.basename(p) for p in wav_paths]}")

    # Generate a unique task ID for this request
    task_uuid = uuid.uuid4()
    task_id = f"{task_uuid}"
    task_name = "sync_local_files"
    # Save the initial task status in the database

    print(f"Generated task_id: {task_id}")
    print(f"Generated task_name: {task_name}")

    # Convert UUID to string
    task_id_str = str(task_id)


    # Save the initial task status in the database
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO tasks (task_id, task_name, uid, status, created_at, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s)
    ''', (task_id_str, task_name, uid, "processing", datetime.now(), datetime.now()))
    conn.commit()

    # Confirm the task is created in the database
    cursor.execute('''
        SELECT task_id, task_name, uid, status, created_at, updated_at
        FROM tasks
        WHERE task_id = %s
    ''', (task_id,))
    task = cursor.fetchone()
    conn.close()
    if task:
        print(f"Task created in the database: {task}")
    else:
        print("Failed to create task in the database.")
        raise HTTPException(status_code=500, detail="Failed to create task in the database.")

    conn.close()

    # Schedule the processing in the background with pipeline selection
    executor.submit(process_in_background, task_id, uid, user_dir, pipeline)
    
    return {
        "message": f"Files received and are being processed using {pipeline} pipeline.",
        "task_id": task_id
    }
# @router.post("/v1/sync-local-files")
# async def sync_local_files(
#     files: List[UploadFile] = File(...), 
#     uid: str = Header(None),
#     pipeline: str = Query("whisperx", enum=["whisperx", "deepgram"])  # This enables pipeline selection
# ):
#     if not uid:
#         raise HTTPException(status_code=400, detail="Missing uid header")

#     user_dir = f"syncing/{uid}/"
#     os.makedirs(user_dir, exist_ok=True)

#     bin_paths = []
#     for file in files:
#         file_path = os.path.join(user_dir, file.filename)
#         with open(file_path, "wb") as buffer:
#             buffer.write(await file.read())
#         bin_paths.append(file_path)

#     try:
#         wav_paths = decode_files_to_wav(bin_paths)
#     except HTTPException as e:
#         raise e  # Propagate the error to the client

#     task_uuid = uuid.uuid4()
#     task_id = f"task_{uid}_{task_uuid}"

#     conn = get_db_connection()
#     cursor = conn.cursor()
#     cursor.execute('''
#         INSERT INTO tasks (task_id, task_name, uid, status, created_at, updated_at)
#         VALUES (%s, %s, %s, %s, %s, %s)
#     ''', (task_id, "sync_local_files", uid, "processing", datetime.now(), datetime.now()))
#     conn.commit()
#     conn.close()

#     # Schedule the processing in the background with pipeline selection
#     process_in_background.delay(task_id, uid, user_dir, pipeline)  # Use .delay() here

#     return {
#         "message": f"Files received and are being processed using {pipeline} pipeline.",
#         "task_id": task_id
#     }
def decode_opus_file_to_wav(opus_file_path, wav_file_path, sample_rate=16000, channels=1):
    decoder = Decoder(sample_rate, channels)
    with open(opus_file_path, 'rb') as f:
        pcm_data = []
        frame_count = 0
        while True:
            length_bytes = f.read(4)
            if not length_bytes:
                print("End of file reached.")
                break
            if len(length_bytes) < 4:
                print("Incomplete length prefix at the end of the file.")
                break

            frame_length = struct.unpack('<I', length_bytes)[0]
            # print(f"Reading frame {frame_count}: length {frame_length}")
            opus_data = f.read(frame_length)
            if len(opus_data) < frame_length:
                print(f"Unexpected end of file at frame {frame_count}.")
                break
            try:
                pcm_frame = decoder.decode(opus_data, frame_size=160)
                pcm_data.append(pcm_frame)
                frame_count += 1
            except Exception as e:
                print(f"Error decoding frame {frame_count}: {e}")
                break
        if pcm_data:
            pcm_bytes = b''.join(pcm_data)
            with wave.open(wav_file_path, 'wb') as wav_file:
                wav_file.setnchannels(channels)
                wav_file.setsampwidth(2)  # 16-bit audio
                wav_file.setframerate(sample_rate)
                wav_file.writeframes(pcm_bytes)
            print(f"Decoded audio saved to {wav_file_path}")
        else:
            print("No PCM data was decoded.")


def get_timestamp_from_path(path: str):
    timestamp = int(path.split('/')[-1].split('_')[-1].split('.')[0])
    if timestamp > 1e10:
        return int(timestamp / 1000)
    return timestamp


def retrieve_file_paths(files: List[UploadFile], uid: str):
    directory = f'syncing/{uid}/'
    os.makedirs(directory, exist_ok=True)
    paths = []
    for file in files:
        filename = file.filename
        # Validate the file is .bin and contains a _$timestamp.bin, if not, 400 bad request
        if not filename.endswith('.bin'):
            raise HTTPException(status_code=400, detail=f"Invalid file format {filename}")
        if '_' not in filename:
            raise HTTPException(status_code=400, detail=f"Invalid file format {filename}, missing timestamp")
        try:
            timestamp = get_timestamp_from_path(filename)
        except ValueError:
            raise HTTPException(status_code=400, detail=f"Invalid file format {filename}, invalid timestamp")

        time = datetime.fromtimestamp(timestamp)
        if time > datetime.now() or time < datetime(2024, 1, 1):
            raise HTTPException(status_code=400, detail=f"Invalid file format {filename}, invalid timestamp")

        path = f"{directory}{filename}"
        paths.append(path)
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

            
    return paths


def decode_files_to_wav(files_path: List[str]):
    wav_files = []
    for path in files_path:
        wav_path = path.replace('.bin', '.wav')
        decode_opus_file_to_wav(path, wav_path)
        try:
            aseg = AudioSegment.from_wav(wav_path)
        except Exception as e:
            print(e)
            raise HTTPException(status_code=400, detail=f"Invalid file format {path}, {e}")

        if aseg.duration_seconds < 1:
            os.remove(wav_path)
            continue
        wav_files.append(wav_path)
        os.remove(path)
    return wav_files
def merge_segments(segments, max_gap=120):
    """
    Merge small segments based on their proximity and speaker identity.
    
    Args:
        segments (list): List of transcript segments with 'start', 'end', 'text', and 'speaker' keys.
        max_gap (float): Maximum gap (in seconds) allowed between segments to merge them.
    
    Returns:
        list: Merged list of segments.
    """
    merged_segments = []
    for segment in segments:
        # Check if the previous segment exists, has the same speaker, and the gap is within the threshold
        if (
            merged_segments and 
            segment['speaker'] == merged_segments[-1]['speaker'] and 
            (segment['start'] - merged_segments[-1]['end']) < max_gap
        ):
            # Merge with the previous segment
            merged_segments[-1]['end'] = segment['end']
            merged_segments[-1]['text'] += " " + segment['text']
        else:
            merged_segments.append(segment)
    return merged_segments

    
def retrieve_vad_segments(path: str, segmented_paths: set):
    start_timestamp = get_timestamp_from_path(path)
    voice_segments = vad_is_empty(path, return_segments=True, cache=True)
    print('voice_segments:', voice_segments)
    segments = []
    # should we merge more aggressively, to avoid too many small segments? ~ not for now
    # Pros -> lesser segments, faster, less concurrency
    # Cons -> less accuracy.

    # edge case, multiple small segments that map towards the same memory .-.
    # so ... let's merge them if distance < 120 seconds
    # a better option would be to keep here 1s, and merge them like that after transcribing
    # but FAL has 10 RPS limit, **let's merge it here for simplicity for now**
   
    for i, segment in enumerate(voice_segments):
        if segments and (segment['start'] - segments[-1]['end']) < 120:
            segments[-1]['end'] = segment['end']
        else:
            segments.append(segment)
    print('voice_segments:', voice_segments)
    print(path, segments)

    aseg = AudioSegment.from_wav(path)
    print('aseg:', aseg.duration_seconds)
    path_dir = '/'.join(path.split('/')[:-1])
    print('path_dir:', path_dir)
    for i, segment in enumerate(segments):
        if (segment['end'] - segment['start']) < 1:
            continue
        segment_timestamp = start_timestamp + segment['start']
        segment_path = f'{path_dir}/{segment_timestamp}.wav'
        segment_aseg = aseg[segment['start'] * 1000:segment['end'] * 1000]
        segment_aseg.export(segment_path, format='wav')
        segmented_paths.add(segment_path)


def process_segment(path: str, uid: str, response: dict):
    url = get_syncing_file_temporal_signed_url(path)

    def delete_file():
        time.sleep(480)
        delete_syncing_temporal_file(path)

    threading.Thread(target=delete_file).start()

    words, language = fal_whisperx(url, 3, 2, True)
    transcript_segments: List[TranscriptSegment] = fal_postprocessing(words, 0)
    if not transcript_segments:
        print('failed to get fal segments')
        return

    timestamp = get_timestamp_from_path(path)
    closest_memory = get_closest_memory_to_timestamps(uid, timestamp, timestamp + transcript_segments[-1].end)

    if not closest_memory:
        create_memory = CreateMemory(
            started_at=datetime.fromtimestamp(timestamp),
            finished_at=datetime.fromtimestamp(timestamp + transcript_segments[-1].end),
            transcript_segments=transcript_segments
        )
        created = process_memory(uid, language, create_memory)
        response['new_memories'].add(created.id)
    else:
        transcript_segments = [s.dict() for s in transcript_segments]

        # assign timestamps to each segment
        for segment in transcript_segments:
            segment['timestamp'] = timestamp + segment['start']
        for segment in closest_memory['transcript_segments']:
            segment['timestamp'] = closest_memory['started_at'].timestamp() + segment['start']

        # merge and sort segments by start timestamp
        segments = closest_memory['transcript_segments'] + transcript_segments
        segments.sort(key=lambda x: x['timestamp'])

        # fix segment.start .end to be relative to the memory
        for i, segment in enumerate(segments):
            duration = segment['end'] - segment['start']
            segment['start'] = segment['timestamp'] - closest_memory['started_at'].timestamp()
            segment['end'] = segment['start'] + duration

        print('reordered segments:')
        for segment in segments:
            print(round(segment['start'], 2), round(segment['end'], 2), segment['text'])

        # remove timestamp field
        for segment in segments:
            segment.pop('timestamp')

        # save
        response['updated_memories'].add(closest_memory['id'])
        update_memory_segments(uid, closest_memory['id'], segments)

# @router.post("/v1/sync-local-files")
# async def sync_local_files(
#     files: List[UploadFile] = File(...), 
#     uid: str = Header(None),
#     pipeline: str = Query("whisperx", enum=["whisperx", "deepgram"])  # This enables pipeline selection
# ):
#     if not uid:
#         raise HTTPException(status_code=400, detail="Missing uid header")

#     print("User ID:", uid)
    
#     user_dir = f"syncing/{uid}/"
#     os.makedirs(user_dir, exist_ok=True)
#     paths = []

    
#     # Save uploaded files to the user's directory
#     bin_paths = []
#     for file in files:
#         file_path = os.path.join(user_dir, file.filename)
#         with open(file_path, "wb") as buffer:
#             buffer.write(await file.read())
#         bin_paths.append(file_path)


#     print(f"Files saved to {user_dir}: {[os.path.basename(p) for p in paths]}")
#         # Decode .bin files to .wav format
#     try:
#         wav_paths = decode_files_to_wav(bin_paths)
#     except HTTPException as e:
#         raise e  # Propagate the error to the client

#     print(f"Decoded files: {[os.path.basename(p) for p in wav_paths]}")

#     # Generate a unique task ID for this request
#     task_uuid = uuid.uuid4()
#     task_id = f"task_{uid}_{task_uuid}"
#     task_name = "sync_local_files"
#     # Save the initial task status in the database

#     print(f"Generated task_id: {task_id}")
#     print(f"Generated task_name: {task_name}")

#     # Save the initial task status in the database
#     conn = get_db_connection()
#     cursor = conn.cursor()
#     cursor.execute('''
#         INSERT INTO tasks (task_id, task_name, uid, status, created_at, updated_at)
#         VALUES (%s, %s, %s, %s, %s, %s)
#     ''', (task_id, task_name, uid, "processing", datetime.now(), datetime.now()))
#     conn.commit()

#     # Confirm the task is created in the database
#     cursor.execute('''
#         SELECT task_id, task_name, uid, status, created_at, updated_at
#         FROM tasks
#         WHERE task_id = %s
#     ''', (task_id,))
#     task = cursor.fetchone()
#     conn.close()
#     if task:
#         print(f"Task created in the database: {task}")
#     else:
#         print("Failed to create task in the database.")
#         raise HTTPException(status_code=500, detail="Failed to create task in the database.")

#     conn.close()

#     # Schedule the processing in the background with pipeline selection
#     executor.submit(process_in_background, task_id, uid, user_dir, pipeline)
    
#     return {
#         "message": f"Files received and are being processed using {pipeline} pipeline.",
#         "task_id": task_id
#     }



# @router.post("/v1/sync-local-files")
# async def sync_local_files(
#     files: List[UploadFile] = File(...), 
#     uid: str = Header(None),
#     pipeline: str = Query("whisperx", enum=["whisperx", "deepgram"])
# ):
#     if not uid:
#         raise HTTPException(status_code=400, detail="Missing uid header")

#     user_dir = f"syncing/{uid}/"
#     os.makedirs(user_dir, exist_ok=True)

#     bin_paths = []
#     for file in files:
#         file_path = os.path.join(user_dir, file.filename)
#         with open(file_path, "wb") as buffer:
#             buffer.write(await file.read())
#         bin_paths.append(file_path)

#     try:
#         wav_paths = decode_files_to_wav(bin_paths)
#     except HTTPException as e:
#         raise e  # Propagate the error to the client

#     task_uuid = uuid.uuid4()
#     task_id = f"task_{uid}_{task_uuid}"

#     conn = get_db_connection()
#     cursor = conn.cursor()
#     cursor.execute('''
#         INSERT INTO tasks (task_id, task_name, uid, status, created_at, updated_at)
#         VALUES (%s, %s, %s, %s, %s, %s)
#     ''', (task_id, "sync_local_files", uid, "processing", datetime.now(), datetime.now()))
#     conn.commit()
#     conn.close()

#     # Submit the task to Celery
#     process_in_background.delay(task_id, uid, user_dir, pipeline)

#     return {
#         "message": f"Files received and are being processed using {pipeline} pipeline.",
#         "task_id": task_id
#     }
def update_memory_with_transcript(uid, transcript_segments):
    for segment in transcript_segments:
        timestamp = segment['start']
        closest_memory = get_closest_memory_to_timestamps(uid, timestamp, segment['end'])
        if not closest_memory:
            # Create a new memory
            create_memory = CreateMemory(
                started_at=datetime.fromtimestamp(segment['start']),
                finished_at=datetime.fromtimestamp(segment['end']),
                transcript_segments=[segment]
            )
            process_memory(uid, "en", create_memory)
        else:
            # Update existing memory
            closest_memory['transcript_segments'].append(segment)
            update_memory_segments(uid, closest_memory['id'], closest_memory['transcript_segments'])

@router.get("/v1/status/{task_id}")
def get_task_status(task_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('''
        SELECT task_id, task_name, uid, status, result, error, created_at, updated_at
        FROM tasks
        WHERE task_id = %s
    ''', (task_id,))
    task = cursor.fetchone()
    conn.close()

    if task:
        print(f"Task status: {task}")
        return {
            "task_id": task[0],
            "task_name": task[1],
            "uid": task[2],
            "status": task[3],
            "result": task[4],
            "error": task[5],
            "created_at": task[6],
            "updated_at": task[7]
        }
    else:
        print(f"Task {task_id} not found.")
        return {"status": "not_found"}