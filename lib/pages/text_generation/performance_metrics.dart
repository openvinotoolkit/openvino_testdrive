// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/widgets/horizontal_rule.dart';
import 'package:inference/widgets/grid_container.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/widgets/metrics_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PerformanceMetrics extends StatelessWidget {
  final Project project;
  const PerformanceMetrics({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
        locale: locale.languageCode, decimalDigits: 0);

    return Row(
      children: [
        Expanded(
          child: GridContainer(
            child: Consumer<TextInferenceProvider>(
              builder: (context, inference, child) {
                final metrics = inference.metrics;
                if (metrics == null) {
                  return Container();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: SizedBox(
                      width: 924,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MetricsCard(
                                header:  "Time to first token (TTFT)",
                                value: nf.format(metrics.ttft),
                                unit: "ms",
                              ),
                              MetricsCard(
                                header: "Time per output token (TPOT)",
                                value: nf.format(metrics.tpot),
                                unit: "ms",
                              ),
                              MetricsCard(
                                header: "Generate total duration",
                                value: nf.format(metrics.generate_time),
                                unit: "ms",
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: HorizontalRule(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MetricsCard(
                                header: "Load time",
                                value: nf.format(metrics.load_time),
                                unit: "ms",
                              ),
                              MetricsCard(
                                header: "Detokenization duration",
                                value: nf.format(metrics.detokenization_time),
                                unit: "ms",
                              ),
                              MetricsCard(
                                header: "Throughput",
                                value: nf.format(metrics.throughput),
                                unit: "tokens/sec",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ),
      ],
    );
  }
}