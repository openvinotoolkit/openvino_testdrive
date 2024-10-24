import 'package:flutter/material.dart';
import 'package:inference/inference/text/metric_widgets.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:intl/intl.dart';

class TTICirclePropRow extends StatelessWidget {
  final TTIMetrics metrics;

  const TTICirclePropRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
        locale: locale.languageCode, decimalDigits: 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleProp(
          header: "Time to load model",
          value: nf.format(metrics.load_time),
          unit: "ms",
        ),
        CircleProp(
          header: "Time to generate image",
          value: nf.format(metrics.generate_time),
          unit: "ms",
        )
      ],
    );
  }
}
