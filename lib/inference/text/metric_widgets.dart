import 'package:flutter/material.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/theme.dart';
import 'package:intl/intl.dart';

class CirclePropRow extends StatelessWidget {
  final Metrics metrics;
  const CirclePropRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPatternDigits(
        locale: locale.languageCode, decimalDigits: 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleProp(
          header: "Time to first token (ttft)",
          value: nf.format(metrics.ttft),
          unit: "ms",
        ),
        CircleProp(
          header: "Time per output token (tpot)",
          value: nf.format(metrics.tpot),
          unit: "ms",
        ),
        CircleProp(
          header: "Generate total duration",
          value: nf.format(metrics.generate_time),
          unit: "ms",
        )
      ],
    );
  }
}

class CircleProp extends StatelessWidget {
  final String header;
  final String value;
  final String unit;

  const CircleProp({super.key, required this.header, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 250.0,
        height: 250.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: intelGrayDark,
          border: Border.all(
            color: intelBlueDark,
            width: 10,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36.0),
              child: SizedBox(
                width: 170,
                child: Text(header,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 46.0),
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(unit,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )

      ),
    );
  }
}

class Statistic extends StatelessWidget {
  const Statistic({
    super.key,
    required this.header,
    required this.value,
    required this.unit,
  });

  final String header;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header),
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(value,
              style: const TextStyle(
                fontSize: 30,
              )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(unit,
                style: const TextStyle(
                  fontSize: 12,
                )
              ),
            ),
          ],
        ),
      ]
    );
  }
}
