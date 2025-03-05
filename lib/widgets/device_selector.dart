// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:collection/collection.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:provider/provider.dart';

class DeviceSelector extends StatelessWidget {
  final String device = "Auto";
  final bool npuSupported;
  const DeviceSelector({super.key, required this.npuSupported});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreferenceProvider>(builder: (context, preferences, child) {
        final currentDevice = PreferenceProvider.availableDevices.firstWhereOrNull((d) => d.id == preferences.device)?.name ?? preferences.device;
        final availableDevices = PreferenceProvider.availableDevices;
        if (!npuSupported) {
          availableDevices.removeWhere((device) => device.id == "NPU");
        }
        return DropDownButton(
          buttonBuilder: (context, callback) {
            return NoOutlineButton(
              onPressed: callback,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text("Device: $currentDevice"),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(FluentIcons.chevron_down, size: 12),
                    ),
                  ],
                ),
              ),
            );
          },
          items: [
            for (final device in availableDevices)
              MenuFlyoutItem(text: Text(device.name), onPressed: () => preferences.device = device.id)
          ]
        );
      }
    );
  }

}
