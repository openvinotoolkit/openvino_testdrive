import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/widgets/horizontal_rule.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/models/widgets/grid_container.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/project.dart';
import 'package:inference/widgets/performance_tile.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PerformanceMetrics extends StatelessWidget {
  final Project project;
  const PerformanceMetrics({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GridContainer(
            child: Consumer<SpeechInferenceProvider>(
              builder: (context, inference, child) {
                final metrics = inference.metrics;
                if (metrics == null) {
                  return Container();
                }

                Locale locale = Localizations.localeOf(context);
                final nf = NumberFormat.decimalPatternDigits(
                    locale: locale.languageCode, decimalDigits: 0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Center(
                    child: SizedBox(
                      width: 887,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PerformanceTile(
                                title: "Time to first token (TTFT)",
                                value: nf.format(metrics.ttft),
                                unit: "ms",
                                tall: true,
                              ),
                              PerformanceTile(
                                title: "Time per output token (TPOT)",
                                value: nf.format(metrics.tpot),
                                unit: "ms",
                                tall: true,
                              ),
                              PerformanceTile(
                                title: "Generate total duration",
                                value: nf.format(metrics.generateTime),
                                unit: "ms",
                                tall: true,
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                            child: HorizontalRule(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PerformanceTile(
                                title: "Load time",
                                value: nf.format(metrics.loadTime),
                                unit: "ms",
                              ),
                              PerformanceTile(
                                title: "Detokenization duration",
                                value: nf.format(metrics.detokenizationTime),
                                unit: "ms",
                              ),
                              PerformanceTile(
                                title: "Throughput",
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
        ModelProperties(project: project),
      ],
    );
  }
}
