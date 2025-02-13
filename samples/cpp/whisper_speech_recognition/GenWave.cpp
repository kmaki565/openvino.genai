#include <Windows.h>
#include <filesystem>
#include "GenWave.h"

// Convert the input file to a wave file. If failed, return an empty string.
std::string PrepareWave(const std::string& inputFile) {
    std::filesystem::path inputPath(inputFile);

    if (!std::filesystem::exists(inputPath)) {
		return "";
	}

    // If the input is a wave file, skip the conversion (hope the format is matched)
    if (inputPath.extension() == ".wav") 
        return inputFile;

    // Create a temp folder
    char tempPath[MAX_PATH];
    GetTempPath(MAX_PATH, tempPath);

    char appTempPath[MAX_PATH];
    snprintf(appTempPath, MAX_PATH, "%s%s", tempPath, "WhisperOv");

    if (GetFileAttributes(appTempPath) == INVALID_FILE_ATTRIBUTES) {
		CreateDirectory(appTempPath, NULL);
	}

    // Extract the base name of the input file
    std::string inputFileBase = inputPath.stem().string();

    // Convert the input file to a wave file
	char wavePath[MAX_PATH];
	snprintf(wavePath, MAX_PATH, "%s\\%s.wav", appTempPath, inputFileBase.c_str());

	char command[MAX_PATH * 2];
	snprintf(command, MAX_PATH * 2, "ffmpeg -y -i \"%s\" -ar 16000 -ac 1 \"%s\"", inputFile.c_str(), wavePath);
	system(command);    //TODO: Include ffmpeg to the project

    return (std::filesystem::exists(wavePath)) ? wavePath : "";
}

void DeleteWave(const std::string& waveFile) {
	if (std::filesystem::exists(waveFile))
        std::filesystem::remove(waveFile);
}