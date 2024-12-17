// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

// ignore_for_file: unused_import

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class DeviceSelector extends StatefulWidget {
  const DeviceSelector({super.key});

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
                  items: PreferenceProvider.availableDevices.map<ComboBoxItem<String>>((e) {
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
