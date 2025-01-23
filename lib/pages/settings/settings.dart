// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/config.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/utils.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _proxyController;

  @override
  void initState() {
    super.initState();
    _proxyController = TextEditingController(text: Config.proxy);
  }

  @override
  void dispose() {
    _proxyController.dispose();
    super.dispose();
  }

  Widget buildSettingSection({
    required String title,
    required String description,
    required Widget child,
    bool isWide = false,
  }) {
    return isWide
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(color: subtleTextColor.of(FluentTheme.of(context)), fontSize: 12),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
              child,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(color: subtleTextColor.of(FluentTheme.of(context)), fontSize: 12),
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 8),
              child,
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<AppTheme>(context);
    return ScaffoldPage(
      header: const PageHeader(title: Text('Settings')),
      content: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 589;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSettingSection(
                  title: 'Appearance',
                  description: 'Select the color theme for the application.',
                  child: ComboBox<ThemeMode>(
                    value: theme.mode,
                    items: ThemeMode.values.map((mode) {
                      return ComboBoxItem<ThemeMode>(
                        value: mode,
                        child: Text(mode.toString().split('.').last.capitalize()),
                      );
                    }).toList(),
                    onChanged: (mode) {
                      if (mode != null) {
                        setState(() {
                          theme.mode = mode;
                        });
                      }
                    },
                  ),
                  isWide: isWide,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),
                buildSettingSection(
                  title: 'HTTPS Proxy',
                  description: 'Configure the proxy settings for network connections. Leave empty to auto-configure.',
                  child: Column(
                    crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      ToggleSwitch(
                        checked: Config.proxyEnabled,
                        onChanged: (value) {
                          setState(() {
                            Config.proxyEnabled = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWide ? 300 : double.infinity),
                        child: TextBox(
                          controller: _proxyController,
                          placeholder: '<username>:<password>@<proxy>:<port>',
                          onChanged: (value) {
                            Config.proxy = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  isWide: isWide,
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}

