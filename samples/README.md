# How to build and run samples
## Build C++ samples
1. Download "OpenVINO with GenAI" Windows package for "OpenVINO Archives" from [Intel's web page](https://www.intel.com/content/www/us/en/developer/tools/openvino-toolkit/download.html)
2. Copy `runtime\lib` and `runtime\bin` of the package to the local repo
3. Open VS Command Prompt and navigate to the root folder
4. Run `setupvars.bat`
5. Move to `samples\cpp` folder
6. Run `build_samples_msvc.bat` (you may see some build errors)
7. It creates a VS solution under `%USERPROFILE%\Documents\Intel\OpenVINO\openvino_cpp_samples_build`
8. You may want to adjust project properties to link `Release` version of `openvino_genai.lib` as `openvino_genaid.lib` is selected by default ![VS Screenshot](ScreenshotVsProperties.png)

## Run C++ samples
1. Copy DLL files in `runtime\bin\intel64` to the same folder as the built executable
2. Copy DLL files in `runtime\3rdparty\tbb\bin` of the downloaded OpenVINO package to the folder
3. (Use [Dependencies](https://github.com/lucasg/Dependencies) to resolve any dependency issues)
4. Follow the instruction in each sample under `openvino.genai/samples/cpp` to run the sample