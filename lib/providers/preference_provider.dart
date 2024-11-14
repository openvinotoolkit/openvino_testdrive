import 'package:flutter/material.dart';
import 'package:inference/interop/device.dart';

class PreferenceProvider extends ChangeNotifier {
    static String defaultDevice = "CPU";
    String _device = defaultDevice;
    String get device => _device;

    PreferenceProvider(this._device);

    set device(String props) {
        if (_device != props) {
            _device = props;
            notifyListeners();
        }
    }

    static List<Device> availableDevices = [];
}
