// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/pages/text_to_image/providers/text_to_image_inference_provider.dart';
import 'package:inference/pages/text_to_image/widgets/model_properties.dart';
import 'package:inference/pages/text_to_image/widgets/toolbar_text_input.dart';
import 'package:inference/pages/text_to_image/widgets/tti_chat_area.dart';
import 'package:inference/pages/text_to_image/widgets/vertical_rule.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';
import 'package:inference/widgets/device_selector.dart';

class TTILiveInferencePane extends StatefulWidget {
  const TTILiveInferencePane({super.key});

  @override
  State<TTILiveInferencePane> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<TTILiveInferencePane> {
  TextToImageInferenceProvider provider() =>
      Provider.of<TextToImageInferenceProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Consumer<TextToImageInferenceProvider>(
        builder: (context, inference, child) {

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: GridContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const DeviceSelector(),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: VerticalRule()),
                          ToolbarTextInput(
                              marginLeft: 0,
                              labelText: "Width",
                              suffix: "px",
                              initialValue: provider().width,
                              roundPowerOfTwo: true,
                              onChanged: (value) { provider().width = value; }),
                          ToolbarTextInput(
                            marginLeft: 20,
                              labelText: "Height",
                              suffix: "px",
                              initialValue: provider().height,
                              roundPowerOfTwo: true,
                              onChanged: (value) { provider().height = value; }),
                          ToolbarTextInput(
                              marginLeft: 20,
                              labelText: "Rounds",
                              suffix: "",
                              initialValue: provider().rounds,
                              onChanged: (value) { provider().rounds = value; }),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridContainer(
                    color: backgroundColor.of(theme),
                    child: Builder(builder: (context) {
                      return const TTIChatArea();
                    }),
                  ),
                )
              ],
            ),
          ),
          const ModelProperties(),
        ],
      );
    });
  }
}




