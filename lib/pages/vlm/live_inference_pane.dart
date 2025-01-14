// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/pages/vlm/providers/vlm_inference_provider.dart';
import 'package:inference/pages/vlm/widgets/model_properties.dart';
import 'package:inference/pages/vlm/widgets/toolbar_text_input.dart';
import 'package:inference/pages/vlm/widgets/vlm_chat_area.dart';
import 'package:inference/pages/vlm/widgets/vertical_rule.dart';
import 'package:inference/theme_fluent.dart';
import 'package:provider/provider.dart';
import 'package:inference/widgets/device_selector.dart';

class VLMLiveInferencePane extends StatefulWidget {
  const VLMLiveInferencePane({super.key});

  @override
  State<VLMLiveInferencePane> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<VLMLiveInferencePane> {
  VLMInferenceProvider provider() =>
      Provider.of<VLMInferenceProvider>(context, listen: false);


  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    const vlmChatArea = VLMChatArea();

    return Consumer<VLMInferenceProvider>(builder: (context, inference, child) {
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
                              labelText: "Max new tokens",
                              suffix: "",
                              initialValue: provider().maxTokens,
                              roundPowerOfTwo: true,
                              onChanged: (value) {
                                provider().maxTokens = value;
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridContainer(
                    color: backgroundColor.of(theme),
                    child: Builder(builder: (context) {
                      return vlmChatArea;
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
