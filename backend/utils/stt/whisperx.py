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

# huggingface_token ="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"
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
    # print('Speaker assignment completed')
    # print(f"Result with speakers: {result}")
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
        transcript_text += f"{segment['start']} - {segment['end']}: {segment['text']}\n"
    
    save_transcript_to_file(transcript_text, audio_file)
    
    # Classify segments (your existing code logic)
    return transcript_text

def process_all_audio_files(directory="syncing/user123/"):
    """Process all audio files in the specified directory and return combined transcripts."""
    if not os.path.exists(directory):
        os.makedirs(directory)
        print(f"Created '{directory}' folder. Place audio files inside.")
        return []

    audio_files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith(('.wav', '.mp3'))]
    if not audio_files:
        print(f"No audio files found in the '{directory}' folder.")
        return []

    combined_transcripts = []
    for audio_file in audio_files:
        print(f"Processing: {audio_file}")
        transcript_text = process_pipeline(audio_file)
        combined_transcripts.append({
           
            "transcript_text": transcript_text
        })

    return combined_transcripts

# if __name__ == "__main__":
#     print("Starting audio transcription pipeline...")
#     process_all_audio_files