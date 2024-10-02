import 'package:flutter/material.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/theme.dart';
import 'package:provider/provider.dart';

class DeviceSelector extends StatelessWidget {
  const DeviceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Device: "),
        Consumer<PreferenceProvider>(builder: (context, preferences, child) {
            return DropdownButton<String>(
              onChanged: (value) {
                preferences.device = value!;
              },
              underline: Container(
                      height: 0,
              ),
              style: const TextStyle(
                fontSize: 12.0,
              ),
              focusColor: intelGrayDark,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              value: preferences.device,
              items: PreferenceProvider.availableDevices.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value.id,
                    child: Text(value.name),
                  );
              }).toList()
            );
          }
        ),
      ],
    );
  }
}
