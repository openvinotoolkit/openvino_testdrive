// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/providers/text_to_image_inference_provider.dart';
import 'package:inference/widgets/metrics_card.dart';
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



class TTIMetricsGrid extends StatelessWidget {
  final TTIMetrics metrics;

  const TTIMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
        locale: locale.languageCode, decimalDigits: 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min, // Wrap content
      children: [
        MetricsCard(
          header: "Time to load model",
          value: nf.format(metrics.load_time),
          unit: "ms",
        ),
        MetricsCard(
          header: "Time to generate image",
          value: nf.format(metrics.generate_time),
          unit: "ms",
        )
      ],
    );
  }
}
