// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/text_to_image/providers/text_to_image_inference_provider.dart';
import 'package:inference/pages/text_to_image/widgets/tti_metrics_grid.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TTIPerformanceMetricsPane extends StatefulWidget {
  const TTIPerformanceMetricsPane({super.key});

  @override
  State<TTIPerformanceMetricsPane> createState() => _TTIPerformanceMetricsPaneState();
}

class _TTIPerformanceMetricsPaneState extends State<TTIPerformanceMetricsPane> {

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TextToImageInferenceProvider>(context, listen: false);
    if (provider.metrics == null) {
      provider.loaded.future.then((_) {
          provider.message("Generate OpenVINO logo");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TextToImageInferenceProvider>(builder: (context, inference, child) {
        if (inference.metrics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/intel-loading.gif', width: 100),
                const Text("Running benchmark prompt...")
              ],
            )
          );
        }

        Locale locale = Localizations.localeOf(context);
        final nf = NumberFormat.decimalPatternDigits(
            locale: locale.languageCode, decimalDigits: 0);

        final metrics = inference.metrics!;

        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TTIMetricsGrid(metrics: metrics),
              ],
            ),
          ),
        );
    });
  }
}


