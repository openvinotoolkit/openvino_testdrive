import 'package:flutter/material.dart';
import 'package:inference/inference/text/metric_widgets.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:inference/utils/dialogs.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PerformanceMetricsPage extends StatefulWidget {
  const PerformanceMetricsPage({super.key});

  @override
  State<PerformanceMetricsPage> createState() => _PerformanceMetricsPageState();
}

class _PerformanceMetricsPageState extends State<PerformanceMetricsPage> {

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TextInferenceProvider>(context, listen: false);
    if (provider.metrics == null) {
      provider.loaded.future.then((_) {
          provider.message("What is the purpose of OpenVINO?").catchError(onExceptionDialog(context));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TextInferenceProvider>(builder: (context, inference, child) {
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
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: intelGray,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CirclePropRow(metrics: metrics),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.0,
                          padding: const EdgeInsets.only(right: 20.0),
                          crossAxisSpacing: 4.0,
                          crossAxisCount: 3,
                          children: [
                           Statistic(header: "Tokenization duration", value: nf.format(metrics.tokenization_time), unit: "ms"),
                           Statistic(header: "Detokenization duration", value: nf.format(metrics.detokenization_time), unit: "ms"),
                           Statistic(header: "Generated tokens", value: nf.format(metrics.number_of_generated_tokens), unit: ""),
                           Statistic(header: "Load time", value: nf.format(metrics.load_time), unit: "ms"),
                           Statistic(header: "Tokens in the input prompt", value: nf.format(metrics.number_of_input_tokens), unit: ""),
                           Statistic(header: "Throughput", value: nf.format(metrics.throughput), unit: "tokens/sec"),
                          ]
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
    });
  }
}


