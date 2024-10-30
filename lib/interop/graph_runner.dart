
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final ov = getBindings();

class GraphRunner {
  final Pointer<StatusOrGraphRunner> instance;

  GraphRunner(this.instance);

  static Future<GraphRunner> init(String graph) async {
    final result = await Isolate.run(() {
      final graphPtr = graph.toNativeUtf8();
      final status = ov.graphRunnerOpen(graphPtr);
      calloc.free(graphPtr);
      return status;
    });

    if (StatusEnum.fromValue(result.ref.status) != StatusEnum.OkStatus) {
      throw "GraphRunner::Init error: ${result.ref.status} ${result.ref.message.toDartString()}";
    }

    return GraphRunner(result);
  }

  Future<String> get() async {
    return await Isolate.run(() {
      final status = ov.graphRunnerGet(instance.ref.value);

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "GraphRunner::get error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
      final content = status.ref.value.toDartString();
      ov.freeStatusOrString(status);
      return content;
    });
  }

  Future<void> queueImage(String nodeName, int timestamp, Uint8List file) async {
    await Isolate.run(() {
      final _data =  calloc.allocate<Uint8>(file.lengthInBytes);
      final _bytes = _data.asTypedList(file.lengthInBytes);
      _bytes.setRange(0, file.lengthInBytes, file);
      final nodeNamePtr = nodeName.toNativeUtf8();
      final status = ov.graphRunnerQueueImage(instance.ref.value, nodeNamePtr, timestamp, _data, file.lengthInBytes);
      calloc.free(nodeNamePtr);

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "QueueImage error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> queueSerializationOutput(String nodeName, int timestamp, SerializationOutput output) async {
    await Isolate.run(() {
      final nodeNamePtr = nodeName.toNativeUtf8();
      final status = ov.graphRunnerQueueSerializationOutput(instance.ref.value, nodeNamePtr, timestamp, output.json, output.csv, output.overlay);
      calloc.free(nodeNamePtr);

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "QueueSerializationOutput error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }
    });
  }

  Future<void> stop() async {
    final status = ov.graphRunnerStop(instance.ref.value);
    if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
      throw "QueueSerializationOutput error: ${status.ref.status} ${status.ref.message.toDartString()}";
    }
  }

  void close() {
    stop();
  }
}
