import 'package:flutter/material.dart';
import 'package:inference/inference/text/metric_widgets.dart';
import 'package:inference/inference/textToImage/tti_metric_widgets.dart';
import 'package:inference/providers/text_to_image_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TTIPerformanceMetricsPage extends StatefulWidget {
  const TTIPerformanceMetricsPage({super.key});

  @override
  State<TTIPerformanceMetricsPage> createState() => _TTIPerformanceMetricsPageState();
}

class _TTIPerformanceMetricsPageState extends State<TTIPerformanceMetricsPage> {

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
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: intelGray,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TTICirclePropRow(metrics: metrics),
              ],
            ),
          ),
        );
    });
  }
}


