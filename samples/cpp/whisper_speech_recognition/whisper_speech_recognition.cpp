// Copyright (C) 2023-2024 Intel Corporation
// SPDX-License-Identifier: Apache-2.0

#include "audio_utils.hpp"
#include "openvino/genai/whisper_pipeline.hpp"
#define NOMINMAX
#include <Windows.h>

static std::string FormatCurrentTime() {
    auto now = std::chrono::system_clock::now();
    auto in_time_t = std::chrono::system_clock::to_time_t(now);
    std::ostringstream ss;
    ss << std::put_time(std::localtime(&in_time_t), "%Y-%m-%d %X");
    return ss.str();
}

std::string FormatTime(float seconds) {
    int total_seconds = static_cast<int>(seconds);
    int hours = total_seconds / 3600;
    int minutes = (total_seconds % 3600) / 60;
    int secs = total_seconds % 60;
    int millis = static_cast<int>((seconds - std::floor(seconds)) * 1000);

    std::ostringstream ss;
    if (hours > 0) {
        ss << std::setfill('0') << std::setw(2) << hours << ":";
    }
    ss << std::setfill('0') << std::setw(2) << minutes << ":" << std::setfill('0') << std::setw(2) << secs << "."
       << std::setfill('0') << std::setw(3) << millis;
    return ss.str();
}

std::vector<float> SliceRawSpeech(const std::vector<float>& raw_speech, size_t start, size_t end) {
    if (start >= end || end > raw_speech.size()) {
        throw std::out_of_range("Invalid slice indices");
    }
    return std::vector<float>(raw_speech.begin() + start, raw_speech.begin() + end);
}

// trim from start (in place)
inline void ltrim(std::string& s) {
    s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
                return !std::isspace(ch);
            }));
}

int main(int argc, char* argv[]) try {
    if (3 > argc) {
        throw std::runtime_error(std::string{"Usage: "} + argv[0] + " <MODEL_DIR> \"<WAV_FILE_PATH>\"");
    }

    // Set console code page to UTF-8 so console known how to interpret string data
    SetConsoleOutputCP(CP_UTF8);

    std::filesystem::path models_path = argv[1];
    std::string wav_file_path = argv[2];
    std::string device = "NPU";  // GPU, CPU can be used as well

    std::cout << FormatCurrentTime() << " Creating pipeline on " << device << " with models from " << models_path
              << "...\n";
    ov::genai::WhisperPipeline pipeline(models_path, device);

    // ov::genai::WhisperGenerationConfig config(models_path / "generation_config.json");
    ov::genai::WhisperGenerationConfig config = pipeline.get_generation_config();
    config.max_new_tokens = 100;  // increase this based on your speech length
    // 'task' and 'language' parameters are supported for multilingual models only
    // Let Whisper to predict the language
    // config.language = "<|ja|>";  // can switch to <|zh|> for Chinese language
    config.task = "transcribe";
    config.return_timestamps = true;

    std::cout << FormatCurrentTime() << " Reading audio file " << wav_file_path << "...\n";
    ov::genai::RawSpeechInput raw_speech = utils::audio::read_wav(wav_file_path);

    std::cout << FormatCurrentTime() << " Generating text from speech...\n";

    const int windowInSec = 30;
    const int sampleRate = 16000;
    float elapsedTime = 0.0f;

    while (true) {
        size_t endOfWindow = std::min(static_cast<size_t>(elapsedTime + windowInSec) * sampleRate, raw_speech.size());
        ov::genai::RawSpeechInput currentWindow = SliceRawSpeech(raw_speech, elapsedTime * sampleRate, endOfWindow);
        auto result = pipeline.generate(currentWindow, config);
        float endOfChunksInSec = 0.0f;

        // If all chunks have the same text, something wrong happened.
        // TODO: Root cause analysis & fix
        bool isAbnormalResult = false;
        int abnormalThreshold = 6;
        if (result.chunks->size() > abnormalThreshold) {
            bool isOk = false;
            for (size_t i = 0; i < abnormalThreshold; i++) {
                if (result.chunks->at(0).text != result.chunks->at(i).text) {
                    isOk = true;
                    break;
                }
            }
            if (!isOk) {
				isAbnormalResult = true;
			}
        }

        for (auto& chunk : *result.chunks) {
            if (chunk.end_ts < 0) {
                // Workaround if audio is cut off in the middle of a word: Wind up the time a little. 
                endOfChunksInSec += 0.2f;
                break;
			}
            std::cout << FormatTime(elapsedTime + chunk.start_ts) << " --> " << FormatTime(elapsedTime + chunk.end_ts)
                      << "\n";
            if (chunk.end_ts > endOfChunksInSec) {
                endOfChunksInSec = chunk.end_ts;
            }
            ltrim(chunk.text);
            std::cout << chunk.text << "\n\n";
            if (isAbnormalResult) {
                // Ignore the rest of the chunks if they all have the same text.
				break;
			}
        }

        if (!isAbnormalResult && endOfWindow == raw_speech.size()) {
            break;
        }
        elapsedTime += endOfChunksInSec;
        // std::cout << "elapsedTime: " << elapsedTime << "\n";
    }
    std::cout << FormatCurrentTime() << " Transcribing done.\n";

} catch (const std::exception& error) {
    try {
        std::cerr << error.what() << '\n';
    } catch (const std::ios_base::failure&) {
    }
    return EXIT_FAILURE;
} catch (...) {
    try {
        std::cerr << "Non-exception object thrown\n";
    } catch (const std::ios_base::failure&) {
    }
    return EXIT_FAILURE;
}
