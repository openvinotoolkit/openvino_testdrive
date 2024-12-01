import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/pages/text_to_image/widgets/metrics_card.dart';
import 'package:intl/intl.dart';


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