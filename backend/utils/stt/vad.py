import os
from enum import Enum

import numpy as np
import requests
import torch
from fastapi import HTTPException
from pydub import AudioSegment

from database import redis_db

torch.set_num_threads(1)
torch.hub.set_dir('pretrained_models')

USE_ONNX = True  # or False, depending on your needs

if USE_ONNX:
    from silero_vad import (load_silero_vad,
                             read_audio,
                             get_speech_timestamps,
                             save_audio,
                             VADIterator,
                             collect_chunks)
    model = load_silero_vad(onnx=True)  # Use ONNX model
else:
    model, utils = torch.hub.load(repo_or_dir='snakers4/silero-vad', model='silero_vad', force_reload=True)
    (get_speech_timestamps, save_audio, read_audio, VADIterator, collect_chunks) = utils


class SpeechState(str, Enum):
    speech_found = 'speech_found'
    no_speech = 'no_speech'


def is_speech_present(data, vad_iterator, window_size_samples=256):
    data_int16 = np.frombuffer(data, dtype=np.int16)
    data_float32 = data_int16.astype(np.float32) / 32768.0
    has_start, has_end = False, False

    for i in range(0, len(data_float32), window_size_samples):
        chunk = data_float32[i: i + window_size_samples]
        if len(chunk) < window_size_samples:
            break
        speech_dict = vad_iterator(chunk, return_seconds=False)
        if speech_dict:
            print(speech_dict)
            vad_iterator.reset_states()
            return SpeechState.speech_found

    vad_iterator.reset_states()
    return SpeechState.no_speech


def is_audio_empty(file_path, sample_rate=8000):
    wav = read_audio(file_path)
    timestamps = get_speech_timestamps(wav, model, sampling_rate=sample_rate)
    if len(timestamps) == 1:
        prob_not_speech = ((timestamps[0]['end'] / 1000) - (timestamps[0]['start'] / 1000)) < 1
        return prob_not_speech
    return len(timestamps) == 0


def vad_is_empty(file_path, return_segments: bool = False, cache: bool = False):
    caching_key = f'vad_is_empty:{file_path}'
    if cache:
        if exists := redis_db.get_generic_cache(caching_key):
            if return_segments:
                return exists
            return len(exists) == 0

    try:
        with open(file_path, 'rb') as file:
            files = {'file': (file_path.split('/')[-1], file, 'audio/wav')}
            response = requests.post(os.getenv('HOSTED_VAD_API_URL'), files=files)
            segments = response.json()
            if cache:
                redis_db.set_generic_cache(caching_key, segments, ttl=60 * 60 * 24)
            if return_segments:
                return segments
            print('vad_is_empty', len(segments) == 0)
            return len(segments) == 0
    except Exception as e:
        print('vad_is_empty', e)
        if return_segments:
            return []
        return False


def apply_vad_for_speech_profile(file_path: str):
    print('apply_vad_for_speech_profile', file_path)
    voice_segments = vad_is_empty(file_path, return_segments=True)
    if len(voice_segments) == 0:
        raise HTTPException(status_code=400, detail="Audio is empty")
    joined_segments = []
    for i, segment in enumerate(voice_segments):
        if joined_segments and (segment['start'] - joined_segments[-1]['end']) < 1:
            joined_segments[-1]['end'] = segment['end']
        else:
            joined_segments.append(segment)

    # trim silence out of file_path, but leave 1 sec of silence within chunks
    trimmed_aseg = AudioSegment.empty()
    for i, segment in enumerate(joined_segments):
        start = segment['start'] * 1000
        end = segment['end'] * 1000
        trimmed_aseg += AudioSegment.from_wav(file_path)[start:end]
        if i < len(joined_segments) - 1:
            trimmed_aseg += AudioSegment.from_wav(file_path)[end:end + 1000]

    trimmed_aseg.export(file_path, format="wav")
