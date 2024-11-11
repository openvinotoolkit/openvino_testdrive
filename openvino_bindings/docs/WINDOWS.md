# Windows build environment instructions

This is a more comprehensible guide for setting up all the dependencies to build the bindings. 
The dependencies are:
1. Visual Studio Build Tools
2. Python
3. msys
4. Bazel
5. OpenCV
6. OpenVINO

## Visual Studio Build Tools

Download the visual studio build tools from [microsoft](https://visualstudio.microsoft.com/visual-cpp-build-tools/).
During installation add the individual component "MSVC v142 - VS 2019 C++ x64/x86 build tools".

## Python

[Install python](https://www.python.org/downloads/windows/) to a short directory without spaces (e.g. C:/Python313). Python version 3.13 works. 
Make sure that the install directory containing python.exe is added to the user environment "path".

## msys

[Install msys](https://www.msys2.org/) and add "C:\msys64\usr\bin" to the user environment "path".

## Bazel

[Install specific Bazel version](../.bazelversion) or install [bazelisk](https://github.com/bazelbuild/bazelisk).

Setup the following environment variables:
- `BAZEL_VC` => `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC`
- `BAZEL_VS` => `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools`
- `BAZEL_VC_FULL_VERSION` => `BUILD TOOLS VERSION` (e.g. 14.29.30133)
Check C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC folder for the specific version.
- `BAZEL_SH` => `C:\msys64\usr\bin\bash.exe`

## OpenCV 

[Install OpenCV](https://github.com/opencv/opencv/releases) to `C:\opencv` resulting in `C:\opencv\build\...`.

## OpenVINO

[Install OpenVINO with GenAI](https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/2024.5/windows) and install to `C:\Intel\openvino_2024.5.0`



