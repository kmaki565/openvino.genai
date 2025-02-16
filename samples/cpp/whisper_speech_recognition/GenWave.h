#pragma once
#include <string>

std::string wstring_to_string(const std::wstring& wstr);
std::wstring GetAppTempDir();
std::string PrepareWave(const std::wstring& inputFile);
void DeleteWave(const std::string& waveFile);