# import os

# import torch
# import whisperx

# from utils.endpoints import timeit
# from utils.speaker_profile import classify_segments

# device = "cuda" if torch.cuda.is_available() else "cpu"
# batch_size = int(os.getenv('WHISPERX_BATCH_SIZE')) if device == "cuda" else 4
# compute_type = "float16" if device == "cuda" else "int8"

# model = whisperx.load_model("large-v3", device, compute_type=compute_type)

# model_by_language = {
#     'en': whisperx.load_align_model(language_code='en', device=device),
# }

# diarize_model = whisperx.DiarizationPipeline(
#     use_auth_token=os.getenv('HUGGINGFACE_TOKEN'), device=device
# )


# # def _clear_cuda(m):
# #     # delete model if low on GPU resources
# #     print(m)
# #     import gc
# #     gc.collect()
# #     torch.cuda.empty_cache()
# #     del m

# @timeit
# def load_audio(audio_file):
#     audio = whisperx.load_audio(audio_file)
#     print('Loaded audio file')
#     return audio


# # measure time of audio transcription
# @timeit
# def transcribe_audio_file(audio, language='en'):
#     result = model.transcribe(audio, batch_size=batch_size, language=language)
#     # print(result)
#     # print(json.dumps(result))
#     print('Whisper transcription completed')
#     return result


# #  measure time of audio alignment
# @timeit
# def align_audio(result, audio):
#     if result["language"] not in model_by_language:
#         model_by_language[result["language"]] = whisperx.load_align_model(
#             language_code=result["language"], device=device
#         )
#     model_a, metadata = model_by_language[result["language"]]  # more or less instant unless lang != english
#     result = whisperx.align(result["segments"], model_a, metadata, audio, device)
#     print('Alignment completed')
#     return result


# #  measure time of speaker diarization
# @timeit
# def diarize_audio(audio):
#     diarize_segments = diarize_model(audio)
#     print('Diarization completed')
#     return diarize_segments


# # measure time of Speaker assignment
# @timeit
# def assign_word_speakers(diarize_segments, result):
#     result = whisperx.assign_word_speakers(diarize_segments, result)
#     print('Speaker assignment completed')
#     return result


# @timeit
# def pipeline(upload_id: str, uid: str, language: str, audio_file: str):
#     print(f'pipeline processing: {audio_file} language: {language} uid: {uid}')
#     audio = load_audio(audio_file)
#     transcription = transcribe_audio_file(audio, language=language)
#     aligned = align_audio(transcription, audio)
#     diarized = diarize_audio(audio)
#     result = assign_word_speakers(diarized, aligned)
#     for segment in result['segments']:
#         del segment['words']

#     classify_segments(upload_id, result['segments'], audio_file, uid)
#     return result['segments']
import os
import torch
import whisperx
from utils.endpoints import timeit
from utils.speaker_profile import classify_segments
from dotenv import load_dotenv


# Load environment variables from .env file
load_dotenv()

# Device and model settings
device = "cuda" if torch.cuda.is_available() else "cpu"
batch_size = int(os.getenv('WHISPERX_BATCH_SIZE', '8')) if device == "cuda" else 4
compute_type = "float16" if device == "cuda" else "int8"

# Load models
model = whisperx.load_model("large-v3", device, compute_type=compute_type)
model_by_language = {'en': whisperx.load_align_model(language_code='en', device=device)}

# huggingface_token = os.getenv('HUGGINGFACE_TOKEN')

huggingface_token ="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"
print("token, ${huggingface_token}")
if not huggingface_token:
    raise ValueError("HUGGINGFACE_TOKEN is required for diarization.")

diarize_model = whisperx.DiarizationPipeline(
    use_auth_token=huggingface_token, device=device
)

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
        diarize_segments = diarize_model(audio)
        print('Diarization completed')
        print(f"Diarization segments: {diarize_segments}")
        return diarize_segments
    except Exception as e:
        print(f"Diarization failed: {str(e)}")
        return []

@timeit
def assign_word_speakers(diarize_segments, result):
    result = whisperx.assign_word_speakers(diarize_segments, result)
    print('Speaker assignment completed')
    print(f"Result with speakers: {result}")
    return result

@timeit
def save_transcript_to_file(transcript_text, audio_file):
    """Save the transcribed text to a text file."""
    output_file = audio_file.replace('.wav', '.txt').replace('.mp3', '.txt')
    with open(output_file, 'w') as file:
        file.write(transcript_text)
    print(f"Transcript saved to {output_file}")

@timeit
def process_pipeline(audio_file, language='en'):
    audio = load_audio(audio_file)
    transcription = transcribe_audio_file(audio, language=language)
    aligned = align_audio(transcription, audio)
    diarized = diarize_audio(audio)
    result = assign_word_speakers(diarized, aligned)
    
    # Generate and save the final transcript text with timestamps and speaker labels
    transcript_text = ""
    for segment in result['segments']:
        start_time = segment['start']
        end_time = segment['end']
        speaker = segment['words'][0]['speaker'] if 'words' in segment and segment['words'] else 'Unknown'
        text = segment['text']
        transcript_text += f"[{start_time:.2f} - {end_time:.2f}] {speaker}: {text}\n"
    
    save_transcript_to_file(transcript_text, audio_file)
    
    # Classify segments (your existing code logic)
    uid = os.path.basename(audio_file).replace('.wav', '').replace('.mp3', '')
    classify_segments(upload_id=uid, segments=result['segments'], audio_file=audio_file, uid=uid)

    return result['segments']

def process_all_audio_files():
    """Process all audio files in the 'audio' directory."""
    audio_folder = "audio"
    if not os.path.exists(audio_folder):
        os.makedirs(audio_folder)
        print("Created 'audio' folder. Place audio files inside.")
        return

    audio_files = [os.path.join(audio_folder, f) for f in os.listdir(audio_folder) if f.endswith(('.wav', '.mp3'))]
    if not audio_files:
        print("No audio files found in the 'audio' folder.")
        return

    for audio_file in audio_files:
        print(f"Processing: {audio_file}")
        process_pipeline(audio_file)

# if __name__ == "__main__":
#     print("Starting audio transcription pipeline...")
#     process_all_audio_files()