# OpenVINO TestDrive Bindings

## Introduction

This repo contains the dart bindings for OpenVINO TestDrive to run GenAI and Geti Image models.
This acts as c api layer between OpenVINO and dart, wrapping and keeping the state.

## Design

Three classes are available via the bindings:
- LLMInference
- ImageInference
- GraphRunner

### LLMInference

The LLMInference class is a small wrapper for OpenVINO GenAI. It allows you to prompt a LLM.

``` c++
LLMInference model(model_path, "CPU");
auto response = model.prompt("What is OpenVINO?");
```

### ImageInference

This class allows you to run computer vision model inference using OpenVINO Model API.
Once inference is done the results are post processed to easy-to-use output.
You can select per infer request if you want an overlay, json and/or csv output.
The postprocessing of the inference to easy to use results are based on the given `task_type`. 

``` c++
ImageInference model(model_path, TaskType::Detection, "CPU");
auto image = cv::imread(image_path);
auto result = model.infer(image);
auto serialized = model.serialize(result, image, true, true, true); //json, csv, and overlay image

std::cout << serialized["csv"] << std::endl;
std::cout << serialized["json"] << std::endl;
std::cout << serialized["overlay"] << std::endl; // overlay is base64 encoded image
```

### GraphRunner

The GraphRunner allows you to run mediapipe graphs. Currently support is limited and subject to change. 
The current implementation assumes input of OpenCV Image in "input" stream and expects output of std::string in "output" stream.


``` c++
GraphRunner runner;
runner.open_graph(graph);
runner.queue_image(cv::imread(image);)
auto result = runner.get();
```

### Contract

In order to have safe API all implementations are wrapped in a try catch block.
The API calls all return a Status object or StatusOrX in case of return value.

``` c++
enum StatusEnum {
  OkStatus = 0,
  ErrorStatus = -1,
  ...
};

typedef struct {
    StatusEnum status;
    const char* message;
} Status;

typedef struct {
    StatusEnum status;
    const char* message;
    const char* value;
} StatusOrString;
...
```

This allows the user to get the state, error code if occured and the resulting data.
These Status objects do need to be deleted from the heap.

## How to build

This project is built with Bazel. You can use [bazelisk](https://bazel.build/install/bazelisk) which will take the correct bazel version from the .bazelversion file.

Further dependencies which are explained per platform below:
- OpenVINO
- OpenCV

### Windows

[Install OpenVINO Runtime 24.4.0]( https://docs.openvino.ai/2024/get-started/install-openvino.html?PACKAGE=OPENVINO_GENAI&VERSION=v_2024_4_0&OP_SYSTEM=WINDOWS&DISTRIBUTION=ARCHIVE)  with GenAI flavor in `C:/Intel/openvino_24.4.0`.

Build OpenCV in `C:/opencv/build`.
Install ffmpeg: `vcpkg install ffmpeg`.

Install [mediapipe requirements](https://ai.google.dev/edge/mediapipe/framework/getting_started/install#installing_on_windows) and setup the environment variables.

Run: `bazel build -c opt :windows_bindings --action_env PYTHON_BIN_PATH="C://Python312//python.exe"`

The DLLs (with dependencies) will be in `bazel-bin/windows_bindings.tar`

### MacOS

[Install OpenVINO Runtime 24.4.0](https://docs.openvino.ai/2024/get-started/install-openvino.html?PACKAGE=OPENVINO_GENAI&VERSION=v_2024_4_0&OP_SYSTEM=MACOS&DISTRIBUTION=ARCHIVE)  with GenAI flavor in `/opt/intel/openvino_24.4.0` and symlink to `/opt/intel/openvino`.

Install OpenCV: `brew install opencv`
Install ffmpeg: `brew install ffmpeg@6`

Run: `bazel build :macos_bindings`

The .dylib and .so are located in `bazel-bin/macos_bindings.tar`. 

### Linux

[Install OpenVINO Runtime 24.4.0](https://docs.openvino.ai/2024/get-started/install-openvino.html?PACKAGE=OPENVINO_GENAI&VERSION=v_2024_4_0&OP_SYSTEM=LINUX&DISTRIBUTION=ARCHIVE) with GenAI flavor in `/opt/intel/openvino_24.4.0` and symlink to `/opt/intel/openvino`.

Build or install OpenCV to `/usr/local/`.
Install ffmpeg: `sudo apt-get install ffmpeg`.

`bazel build :linux_bindings`

The binaries are located in `bazel-bin/linux_bindings.tar`. 

## How to test

The test models and other data for the inference test still needs to be shared properly (TODO)
For all tests: `bazel test //... --test_output=all`


## Updating dart bindings

The dart bindings are generated using [ffigen](https://pub.dev/packages/ffigen).
Ffigen requires LLVM. See documentation in the link above on how to install.
When applying changes to bindings.h you can update the bindings from the root folder (not ./openvino_bindings) as following:

`dart run ffigen`

## Suppported features

* Platforms: MacOS, Windows
* Image inference
    * Output CSV, JSON and/or Overlay image 
    * Open camera and run inference (WIP)
    * Tasks: Detection, Classification, Anomaly, Segmentation and RotatedDetection
    * Sync inference
    * Async and listener inference
* LLM Inference

## Known issues

* Auto plugin might cause in LLM
