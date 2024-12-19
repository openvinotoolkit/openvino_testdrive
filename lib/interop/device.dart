// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:inference/interop/openvino_bindings.dart';

final deviceOV = getBindings();

class Device {
  final String id;
  final String name;
  const Device(this.id, this.name);

  static Future<List<Device>> getDevices() async {
    final result = await Isolate.run(() {
      final status = deviceOV.getAvailableDevices();

      if (StatusEnum.fromValue(status.ref.status) != StatusEnum.OkStatus) {
        throw "GetAvailableDevices error: ${status.ref.status} ${status.ref.message.toDartString()}";
      }

      List<Device> devices = [];
      for (int i = 0; i < status.ref.size; i++) {
        devices.add(Device(
          status.ref.value[i].id.toDartString(),
          status.ref.value[i].name.toDartString()
        ));
      }
      deviceOV.freeStatusOrDevices(status);

      return devices;
    });

    for (var b in result) {
      print("${b.id}, ${b.name}");
    }

    return result;
  }
}
