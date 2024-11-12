import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();

class SpeechToText {
  final Pointer<StatusOrSpeechToText> instance;



  SpeechToText(this.instance);

  static Future<SpeechToText> init(String modelPath, String device) async {
    throw UnimplementedError();
    //final result = await Isolate.run(() {
    //  final modelPathPtr = modelPath.toNativeUtf8();
    //  final devicePtr = device.toNativeUtf8();
    //  final status = ov.speechToTextOpen(modelPathPtr, devicePtr);
    //  calloc.free(modelPathPtr);
    //  calloc.free(devicePtr);

    //  return status;
    //});

    //print("${result.ref.status}, ${result.ref.message}");
    //if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
    //  throw "SpeechToText open error: ${result.ref.status} ${result.ref.message.toDartString()}";
    //}

    //return SpeechToText(result);
  }

  Future<int> loadVideo(String videoPath) async{
    throw UnimplementedError();
    //int instanceAddress = instance.ref.value.address;
    //{
    //  final result = await Isolate.run(() {
    //    final videoPathPtr = videoPath.toNativeUtf8();
    //    final status = ov.speechToTextLoadVideo(Pointer<Void>.fromAddress(instanceAddress), videoPathPtr);
    //    calloc.free(videoPathPtr);
    //    return status;
    //  });

    //  if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
    //    throw "SpeechToText LoadVideo error: ${result.ref.status} ${result.ref.message.toDartString()}";
    //  }
    //}

    //{
    //  final result = await Isolate.run(() {
    //    final status = ov.speechToTextVideoDuration(Pointer<Void>.fromAddress(instanceAddress));
    //    return status;
    //  });
    //  if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
    //    throw "SpeechToText VideoDuration error: ${result.ref.status} ${result.ref.message.toDartString()}";
    //  }
    //  return result.ref.value;
    //}
  }

  Future<String> transcribe(int start, int duration, String language) async{
    throw UnimplementedError();
    //int instanceAddress = instance.ref.value.address;
    //final result = await Isolate.run(() {
    //  final languagePtr = language.toNativeUtf8();
    //  final status = ov.speechToTextTranscribe(Pointer<Void>.fromAddress(instanceAddress), start, duration, languagePtr);
    //  calloc.free(languagePtr);
    //  return status;
    //});

    //if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
    //  throw "SpeechToText LoadVideo error: ${result.ref.status} ${result.ref.message.toDartString()}";
    //}

    //return result.ref.value.toDartString();
  }
}
