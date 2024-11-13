# OpenVINO™ Test Drive

Get started with OpenVINO Test Drive, an application that allows you to run LLMs and models trained by [Intel Geti](https://geti.intel.com/) directly on your computer or edge device using OpenVINO.

# Features
### LLM models
+ **Text Generation**: Generate text and engage in chat experiences.
+ **Performance metrics**: Evaluate model performance on your computer or edge device.
### Computer vision models
+ **Single Image Inference**: Perform inference on individual images.
+ **Batch Inference**: Conduct inference on batches of images.

# High level architecture
![Design Graph](./design_graph.png)

# Using the Test Drive

Upon starting the application, you can import a model using either Huggingface for LLMs or “from local disk” for Geti models.

![Preview](./preview.png)

# Getting Started

## Release

Download the latest release from the [Releases page](https://github.com/openvinotoolkit/openvino_testdrive/releases).

## Build

The application requires the flutter SDK and the dependencies for your specific platform to be installed.
Secondly, the bindings and its dependencies for your platform to be added to `./bindings`.

1. [Install flutter sdk](https://docs.flutter.dev/get-started/install). Make sure to follow the guide for flutter dependencies.
2. [Download the bindings](https://github.com/intel-sandbox/applications.ai.geti.flutter.inference/releases) and extract them to ./bindings folder
3. Once done you can start the application: `flutter run`

## Build bindings

The Test Drive uses c bindings to OpenVINO. These are located in `./openvino_bindings` folder. See [readme.md](./openvino_bindings/README.md).

