// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme_fluent.dart';
import 'package:intl/intl.dart';

class LLMOptions extends StatelessWidget {
  final TextInferenceProvider provider;
  const LLMOptions(this.provider, {super.key});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
      locale: locale.languageCode, decimalDigits: 2);
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Text("Temperature: "),
              Tooltip(
                message: 'Temperature controls the randomness of the output. Higher values mean more random outputs.',
                child: Icon(FluentIcons.info, size: 16, color: subtleTextColor.of(theme),),
              ),
              Slider(
                value: provider.temperature,
                onChanged: (value) { provider.temperature = value; },
                label: nf.format(provider.temperature),
                max: 1.0,
                min: 0.1,
              )
            ]
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              const Text("Top P: "),
              Tooltip(
                message: 'Top P controls the diversity of the output by limiting the selection to a subset of the most probable tokens.',
                child: Icon(FluentIcons.info, size: 16, color: subtleTextColor.of(theme)),
              ),
              Slider(
                value: provider.topP,
                onChanged: (value) { provider.topP = value; },
                label: nf.format(provider.topP),
                max: 2.0,
                min: 0.1,
              )
            ]
          ),
        )
      ]
    );
  }

}
