import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();
class SpeechToText {
  final Pointer<StatusOrSpeechToText> instance;

  SpeechToText(this.instance);

  static Future<SpeechToText> init(String modelPath, String device) async {
    final result = await Isolate.run(() {
      final modelPathPtr = modelPath.toNativeUtf8();
      final devicePtr = device.toNativeUtf8();
      final status = ov.speechToTextOpen(modelPathPtr, devicePtr);
      calloc.free(modelPathPtr);
      calloc.free(devicePtr);

      return status;
    });

    print("${result.ref.status}, ${result.ref.message}");
    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "SpeechToText open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return SpeechToText(result);
  }

  Future<void> loadVideo(String videoPath) async{
    int instanceAddress = instance.ref.value.address;
    final result = await Isolate.run(() {
      final videoPathPtr = videoPath.toNativeUtf8();
      final status = ov.speechToTextLoadVideo(Pointer<Void>.fromAddress(instanceAddress), videoPathPtr);
      calloc.free(videoPathPtr);
      return status;
    });

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "SpeechToText LoadVideo error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }
  }

  Future<String> transcribe(int start, int duration) async{
    int instanceAddress = instance.ref.value.address;
    final result = await Isolate.run(() {
      final status = ov.speechToTextTranscribe(Pointer<Void>.fromAddress(instanceAddress), start, duration);
      return status;
    });

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "SpeechToText LoadVideo error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return result.ref.value.toDartString();
  }
}
