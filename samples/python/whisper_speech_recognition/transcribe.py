import argparse
import openvino_genai
import librosa
from datetime import datetime


def read_wav(filepath):
    raw_speech, samplerate = librosa.load(filepath, sr=None)
    return raw_speech.tolist()

def format_time(time_in_seconds):
    hours = int(time_in_seconds // 3600)
    minutes = int((time_in_seconds % 3600) // 60)
    seconds = time_in_seconds % 60

    if hours > 0:
        return f"{hours:02}:{minutes:02}:{seconds:06.3f}"
    else:
        return f"{minutes:02}:{seconds:06.3f}"
    
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("model_dir")
    parser.add_argument("wav_file_path")
    args = parser.parse_args()

    device = "NPU"  # CPU, GPU can be used as well
    print(datetime.now().time(), "Creating Whisper pipeline... ")
    pipe = openvino_genai.WhisperPipeline(args.model_dir, device)

    config = pipe.get_generation_config()
    config.max_new_tokens = 100  # increase this based on your speech length
    # 'task' and 'language' parameters are supported for multilingual models only
    # Comment out language to let whisper predict the language
    # config.language = "<|en|>"  # can switch to <|zh|> for Chinese, <|ja|> for Japanese language
    config.task = "transcribe"
    config.return_timestamps = True

    # Pipeline expects normalized audio with Sample Rate of 16kHz
    # print current time
    print(datetime.now().time(), "Reading audio file... ")
    raw_speech = read_wav(args.wav_file_path)
    print(datetime.now().time(), "Transcribing...")

    chunk_length_sec = 30
    chunk_length = 16000 * chunk_length_sec
    elapsed_time = 0

    for i in range(0, len(raw_speech), chunk_length):
        big_chunk = raw_speech[i:i + chunk_length]
        result = pipe.generate(big_chunk, config)
        if result.chunks:
            for chunk in result.chunks:
                print(f"{format_time(elapsed_time+chunk.start_ts)} --> {format_time(elapsed_time+chunk.end_ts)}")
                print(chunk.text.strip())
                print()
        elapsed_time += chunk_length_sec

    print(datetime.now().time(), "Transcribing done.")

if "__main__" == __name__:
    main()
