// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:provider/provider.dart';

class DeviceSelector extends StatefulWidget {
  final bool npuSupported;
  const DeviceSelector({super.key, required this.npuSupported});

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  String? selectedDevice;

  @override
  void initState() {
    super.initState();
    selectedDevice = Provider.of<PreferenceProvider>(context, listen: false).device;
  }

  @override
  Widget build(BuildContext context) {
    var availableDevices = PreferenceProvider.availableDevices.where((p) {
        if (!widget.npuSupported && p.id == "NPU") {
          return false;
        }
        return true;
    });

    return Consumer<PreferenceProvider>(builder: (context, preferences, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text("Device",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ComboBox(
                  value: selectedDevice,
                  items: availableDevices.map<ComboBoxItem<String>>((e) {
                    return ComboBoxItem<String>(
                      value: e.id,
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedDevice = v;
                      if (v != null) {
                        preferences.device = v;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
