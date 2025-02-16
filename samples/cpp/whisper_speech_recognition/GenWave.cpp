#include <Windows.h>
#include <filesystem>
#include "GenWave.h"

std::string wstring_to_string(const std::wstring& wstr) {
    int size_needed = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, NULL, 0, NULL, NULL);
    std::string str(size_needed - 1, 0);  // Remove null terminated character
    WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), -1, &str[0], size_needed, NULL, NULL);
    return str;
}

std::wstring GetAppTempDir() {
	wchar_t tempPath[MAX_PATH] = {};
	GetTempPathW(MAX_PATH, tempPath);

	wchar_t appTempDir[MAX_PATH] = {};
	_snwprintf_s(appTempDir, MAX_PATH, L"%s%s", tempPath, L"WhisperOv");

    // Create the app temp folder if not exists
	if (GetFileAttributesW(appTempDir) == INVALID_FILE_ATTRIBUTES) {
		CreateDirectoryW(appTempDir, NULL);
	}

	return std::wstring(appTempDir);
}

// Convert the input file to a wave file. If failed, return an empty string.
std::string PrepareWave(const std::wstring& inputFile) {
    std::filesystem::path inputPath(inputFile);

    if (!std::filesystem::exists(inputPath)) {
		return "";
	}

    // If the input is a wave file, skip the conversion (hope the format is matched)
    if (inputPath.extension() == ".wav")
        return wstring_to_string(inputFile);

    // Create random file name
    GUID guid;
    CoCreateGuid(&guid);
    wchar_t guidWstr[40] = {};
    StringFromGUID2(guid, guidWstr, 40);

    // Convert the input file to a wave file
	wchar_t wavePath[MAX_PATH] = {};
    _snwprintf_s(wavePath, MAX_PATH, L"%s\\%s.wav", GetAppTempDir().c_str(), guidWstr);

	wchar_t commandLine[MAX_PATH * 2] = {};
	_snwprintf_s(commandLine, MAX_PATH * 2, L"ffmpeg.exe -y -i \"%s\" -ar 16000 -ac 1 \"%s\"", inputFile.c_str(), wavePath);

    STARTUPINFOW si = {sizeof(si)};
    PROCESS_INFORMATION pi = {};

	//TODO: Include ffmpeg to the project
    if (CreateProcessW(NULL, commandLine, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
        WaitForSingleObject(pi.hProcess, INFINITE);
		CloseHandle(pi.hProcess);
		CloseHandle(pi.hThread);
	}

    return (std::filesystem::exists(wavePath)) ? wstring_to_string(wavePath) : "";
}

void DeleteWave(const std::string& waveFile) {
	if (std::filesystem::exists(waveFile))
        std::filesystem::remove(waveFile);
}