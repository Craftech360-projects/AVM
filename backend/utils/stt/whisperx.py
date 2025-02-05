# import os
# import torch
# import whisperx
# from utils.endpoints import timeit
# from utils.speaker_profile import classify_segments
# from dotenv import load_dotenv


# # Load environment variables from .env file
# load_dotenv()

# # Device and model settings
# device = "cuda" if torch.cuda.is_available() else "cpu"
# batch_size = int(os.getenv('WHISPERX_BATCH_SIZE', '8')) if device == "cuda" else 4
# compute_type = "float16" if device == "cuda" else "int8"

# # Load models
# model = whisperx.load_model("large-v3", device, compute_type=compute_type)
# model_by_language = {'en': whisperx.load_align_model(language_code='en', device=device)}

# # huggingface_token = os.getenv('HUGGINGFACE_TOKEN')

# huggingface_token ="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"
# print("token, ${huggingface_token}")
# if not huggingface_token:
#     raise ValueError("HUGGINGFACE_TOKEN is required for diarization.")

# diarize_model = whisperx.DiarizationPipeline(
#     use_auth_token=huggingface_token, device=device
# )

# def _clear_cuda(m):
#     """Clear GPU memory after heavy operations."""
#     import gc
#     gc.collect()
#     if torch.cuda.is_available():
#         torch.cuda.empty_cache()
#     del m

# @timeit
# def load_audio(audio_file):
#     audio = whisperx.load_audio(audio_file)
#     print(f"Loaded audio file: {audio_file}")
#     return audio

# @timeit
# def transcribe_audio_file(audio, language='en'):
#     result = model.transcribe(audio, batch_size=batch_size, language=language)
#     print('Whisper transcription completed')
#     return result

# @timeit
# def align_audio(result, audio):
#     if result["language"] not in model_by_language:
#         model_by_language[result["language"]] = whisperx.load_align_model(
#             language_code=result["language"], device=device
#         )
#     model_a, metadata = model_by_language[result["language"]]
#     result = whisperx.align(result["segments"], model_a, metadata, audio, device)
#     print('Alignment completed')
#     return result

# @timeit
# def diarize_audio(audio):
#     try:
#         diarize_segments = diarize_model(audio)
#         print('Diarization completed')
#         print(f"Diarization segments: {diarize_segments}")
#         return diarize_segments
#     except Exception as e:
#         print(f"Diarization failed: {str(e)}")
#         return []

# @timeit
# def assign_word_speakers(diarize_segments, result):
#     result = whisperx.assign_word_speakers(diarize_segments, result)
#     # print('Speaker assignment completed')
#     # print(f"Result with speakers: {result}")
#     return result

# @timeit
# def save_transcript_to_file(transcript_text, audio_file):
#     """Save the transcribed text to a text file."""
#     output_file = audio_file.replace('.wav', '.txt').replace('.mp3', '.txt')
#     with open(output_file, 'w') as file:
#         file.write(transcript_text)
#     print(f"Transcript saved to {output_file}")

# @timeit
# def process_pipeline(audio_file, language='en'):
#     audio = load_audio(audio_file)
#     transcription = transcribe_audio_file(audio, language=language)
#     aligned = align_audio(transcription, audio)
#     diarized = diarize_audio(audio)
#     result = assign_word_speakers(diarized, aligned)
    
#     # Generate and save the final transcript text with timestamps and speaker labels
#     transcript_text = ""
#     for segment in result['segments']:
#         transcript_text += f"{segment['start']} - {segment['end']}: {segment['text']}\n"
    
#     save_transcript_to_file(transcript_text, audio_file)
    
#     # Classify segments (your existing code logic)
#     return transcript_text

# def process_all_audio_files(directory="syncing/user123/"):
#     """Process all audio files in the specified directory and return combined transcripts."""
#     if not os.path.exists(directory):
#         os.makedirs(directory)
#         print(f"Created '{directory}' folder. Place audio files inside.")
#         return []

#     audio_files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(('.wav', '.mp3'))]
#     if not audio_files:
#         print(f"No audio files found in the '{directory}' folder.")
#         return []

#     combined_transcripts = []
#     for audio_file in audio_files:
#         print(f"Processing: {audio_file}")
#         transcript_text = process_pipeline(audio_file)
#         combined_transcripts.append({
           
#             "transcript_text": transcript_text
#         })

#     return combined_transcripts

# if __name__ == "__main__":
#     print("Starting audio transcription pipeline...")
#     process_all_audio_files



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
# from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Device and model settings
device = "cuda" if torch.cuda.is_available() else "cpu"
batch_size = int(os.getenv('WHISPERX_BATCH_SIZE', '8')) if device == "cuda" else 4
compute_type = "float16" if device == "cuda" else "int8"

# Load WhisperX models
model = whisperx.load_model("large-v3", device, compute_type=compute_type)
model_by_language = {'en': whisperx.load_align_model(language_code='en', device=device)}

# Load SpeechBrain speaker recognition model
verification_model = SpeakerRecognition.from_hparams(
    source="speechbrain/spkrec-ecapa-voxceleb",
    savedir="pretrained_models/spkrec-ecapa-voxceleb"
)

# Path to the folder containing sample audio files
sample_folder = "sample"

# Create embeddings for each speaker in the sample folder
speaker_embeddings = {}
for enrollment_audio in os.listdir(sample_folder):
    enrollment_audio_path = os.path.join(sample_folder, enrollment_audio)
    signal = verification_model.load_audio(enrollment_audio_path)
    embedding = verification_model.encode_batch(signal.unsqueeze(0)).squeeze().cpu().numpy()
    speaker_embeddings[enrollment_audio] = embedding  # Use filename as key

@timeit
def _clear_cuda(m):
    """Clear GPU memory after heavy operations."""
    import gc
    gc.collect()
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    del m

@timeit
def load_audio(audio_file):
    audio = whisperx.load_audio(audio_file)
    print(f"Loaded audio file: {audio_file}")
    return audio

@timeit
def transcribe_audio_file(audio, language='en'):
    result = model.transcribe(audio, batch_size=batch_size, language=language)
    print('Whisper transcription completed')
    return result

@timeit
def align_audio(result, audio):
    if result["language"] not in model_by_language:
        model_by_language[result["language"]] = whisperx.load_align_model(
            language_code=result["language"], device=device
        )
    model_a, metadata = model_by_language[result["language"]]
    result = whisperx.align(result["segments"], model_a, metadata, audio, device)
    print('Alignment completed')
    return result

@timeit
def diarize_audio(audio):
    try:
        huggingface_token = "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"
        if not huggingface_token:
            raise ValueError("HUGGINGFACE_TOKEN is required for diarization.")
        
        diarize_model = whisperx.DiarizationPipeline(use_auth_token=huggingface_token, device=device)
        diarize_segments = diarize_model(audio)
        print('Diarization completed')
        print(f"Diarization segments: {diarize_segments}")
        return diarize_segments
    except Exception as e:
        print(f"Diarization failed: {str(e)}")
        return []
@timeit
def assign_word_speakers(diarize_segments, result):
    """Assign initial speaker labels using WhisperX diarization."""
    for segment in result['segments']:
        segment_start = segment['start']
        segment_end = segment['end']
        best_overlap = -1
        best_speaker = None  # Default to None
        
        for _, diarization_segment in diarize_segments.iterrows():
            diarization_start = diarization_segment['start']
            diarization_end = diarization_segment['end']
            speaker_label = diarization_segment['speaker']
            
            # Calculate overlap duration
            overlap_start = max(segment_start, diarization_start)
            overlap_end = min(segment_end, diarization_end)
            overlap_duration = max(0, overlap_end - overlap_start)
            
            # Assign the speaker with the largest overlap
            if overlap_duration > best_overlap:
                best_overlap = overlap_duration
                best_speaker = speaker_label
        
        # Add the 'speaker' key to the segment
        segment['speaker'] = best_speaker if best_speaker else "SPEAKER_UNKNOWN"
    
    print('Initial speaker assignment completed')
    return result

# @timeit
# def map_speakers_to_names(audio_file, result):
#     """Map WhisperX speaker labels (e.g., SPEAKER_00) to actual names using SpeechBrain."""
#     audio_loader = Audio(sample_rate=16000)
#     waveform, _ = audio_loader(audio_file)
#     if waveform.ndim == 2 and waveform.shape[0] == 1:
#         waveform = waveform.squeeze(0)

#     # Dictionary to store mappings from speaker_X to actual names
#     speaker_mapping = {}

#     for segment in result['segments']:
#         # Debug: Print segment structure
#         print(f"Segment: {segment}")

#         # Check if 'speaker' key exists
#         if 'speaker' not in segment:
#             print("Warning: 'speaker' key not found in segment. Skipping...")
#             continue

#         speaker_label = segment['speaker']
#         start_time = segment['start']
#         end_time = segment['end']

#         # Skip if this speaker_X has already been mapped
#         if speaker_label in speaker_mapping:
#             segment['speaker'] = speaker_mapping[speaker_label]
#             continue

#         # Extract the audio segment corresponding to this speaker_X
#         segment_audio = waveform[int(start_time * 16000):int(end_time * 16000)]
#         if segment_audio.size == 0:
#             speaker_mapping[speaker_label] = speaker_label  # Retain original label if no audio
#             segment['speaker'] = speaker_label
#             continue

#         # Generate embedding for the segment
#         segment_tensor = torch.tensor(segment_audio).unsqueeze(0)
#         segment_embedding = verification_model.encode_batch(segment_tensor).squeeze().cpu().numpy()
#         if segment_embedding.ndim == 2:
#             segment_embedding = segment_embedding.squeeze()

#         # Compare with pre-enrolled speaker embeddings
#         best_match = None
#         best_score = -np.inf
#         for speaker_name, speaker_embedding in speaker_embeddings.items():
#             if speaker_embedding.ndim == 2:
#                 speaker_embedding = speaker_embedding.squeeze()
#             # Normalize embeddings
#             segment_embedding_norm = segment_embedding / np.linalg.norm(segment_embedding)
#             speaker_embedding_norm = speaker_embedding / np.linalg.norm(speaker_embedding)
#             score = float(np.dot(segment_embedding_norm, speaker_embedding_norm))
#             print(f"Segment [{start_time:.2f} - {end_time:.2f}] -> {speaker_name.split('.')[0]} (Score: {score:.4f})")
#             if score > best_score:
#                 best_score = score
#                 best_match = speaker_name

#         # Assign name or retain original label
#         if best_score >= 0.6:  # Threshold for matching
#             speaker_mapping[speaker_label] = best_match.split(".")[0]
#         else:
#             speaker_mapping[speaker_label] = speaker_label  # Retain original label

#         # Update the segment's speaker label
#         segment['speaker'] = speaker_mapping[speaker_label]

#     print('Speaker mapping completed')
#     return result



@timeit
def map_speakers_to_names(audio_file, result):
    """Map WhisperX speaker labels (e.g., SPEAKER_00) to actual names using SpeechBrain."""
    audio_loader = Audio(sample_rate=16000)
    waveform, _ = audio_loader(audio_file)
    if waveform.ndim == 2 and waveform.shape[0] == 1:
        waveform = waveform.squeeze(0)

    # Dictionary to store mappings from speaker_X to actual names
    speaker_mapping = {}

    for segment in result['segments']:
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
    return result



@timeit
def save_transcript_to_file(transcript, audio_file):
    """Save the transcribed text in JSON format to a file."""
    output_file = audio_file.replace('.wav', '.json').replace('.mp3', '.json')
    with open(output_file, 'w') as file:
        json.dump(transcript, file, indent=4)
    print(f"Transcript saved to {output_file}")
@timeit
def process_pipeline(audio_file, language='en'):
    # Step 1: Load audio and perform transcription, alignment, and diarization
    audio = load_audio(audio_file)
    transcription = transcribe_audio_file(audio, language=language)
    aligned = align_audio(transcription, audio)
    diarized = diarize_audio(audio)
    
    # Step 2: Assign initial speaker labels using WhisperX diarization
    result = assign_word_speakers(diarized, aligned)
    
    # Step 3: Map speaker_X labels to actual names using SpeechBrain
    result = map_speakers_to_names(audio_file, result)
    
    # Step 4: Generate the transcript in the specified JSON format
    transcript = []
    for segment in result['segments']:
        start_time = segment['start']
        end_time = segment['end']
        speaker = segment.get('speaker', 'SPEAKER_UNKNOWN')  # Retain original label if no match
        text = segment['text']
        
        # Append the segment in the specified JSON format
        transcript.append({
            "text": text,
            "speaker": speaker,
            "start": start_time,
            "end": end_time
        })

    # Save the transcript to a file (optional)
    save_transcript_to_file(transcript, audio_file)
    
    return transcript

@timeit
def save_combined_transcript_to_file(combined_transcript, directory):
    """Save the combined transcript in JSON format to a single file."""
    output_file = os.path.join(directory, "combined_transcript.json")
    with open(output_file, 'w') as file:
        json.dump(combined_transcript, file, indent=4)
    print(f"Combined transcript saved to {output_file}")

@timeit
def process_all_audio_files(directory="syncing/user123/"):
    """Process all audio files in the specified directory and return a combined transcript."""
    if not os.path.exists(directory):
        os.makedirs(directory)
        print(f"Created '{directory}' folder. Place audio files inside.")
        return []
    
    # Get all audio files in the directory
    audio_files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(('.wav', '.mp3'))]
    if not audio_files:
        print(f"No audio files found in the '{directory}' folder.")
        return []
    
    # Initialize an empty list to store the combined transcript
    combined_transcript = []

    for audio_file in audio_files:
        print(f"Processing: {audio_file}")
        # Process each audio file and get its transcript
        transcript = process_pipeline(audio_file)
        
        # Append the transcript segments to the combined transcript
        combined_transcript.extend(transcript)

    # Save the combined transcript to a single JSON file (optional)
    save_combined_transcript_to_file(combined_transcript, directory)
    
    return combined_transcript

# if __name__ == "__main__":
#     print("Starting audio transcription pipeline...")
#     process_all_audio_files()

   