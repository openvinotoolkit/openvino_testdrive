import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/inference/textToImage/tti_performance_metrics.dart';
import 'package:inference/inference/textToImage/tti_playground.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/text_to_image_inference_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TextToImageInferencePage extends StatefulWidget {
  final Project project;
  const TextToImageInferencePage(this.project, {super.key});

  @override
  State<TextToImageInferencePage> createState() => _TextToImageInferencePageState();
}

class _TextToImageInferencePageState extends State<TextToImageInferencePage> with TickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, animationDuration: Duration.zero, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);

    return ChangeNotifierProxyProvider<PreferenceProvider, TextToImageInferenceProvider>(
      create: (_) {
        return TextToImageInferenceProvider(widget.project, null);
      },
      update: (_, preferences, textToImageInferenceProvider) {
        if (textToImageInferenceProvider == null) {
          return TextToImageInferenceProvider(widget.project, preferences.device);
        }
        if (!textToImageInferenceProvider.sameProps(widget.project, preferences.device)) {
          return TextToImageInferenceProvider(widget.project, preferences.device);
        }
        return textToImageInferenceProvider;
      },
      child: Scaffold(
        appBar: const Header(true),
        body: Padding(
          padding: const EdgeInsets.only(left: 58, right: 58, bottom: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<TextToImageInferenceProvider>(
                  builder: (context, inference, child) {
                    final nf = NumberFormat.decimalPatternDigits(
                        locale: locale.languageCode, decimalDigits: 2);

                    return SizedBox(
                      width: 250,
                      child: ModelInfo(
                        widget.project,
                        children: [
                          PropertyItem(
                            name: "Task",
                            child: PropertyValue(inference.task),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 12, right: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Width"),
                                    Text(nf.format(inference.width))
                                  ]
                                ),
                                Slider(
                                  value: inference.width.toDouble(),
                                  max: 1024.0,
                                  min: 64,
                                  divisions: (1024-64)~/64,
                                  onChanged: (double value) {
                                    inference.width = value.toInt();
                                  },

                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 12, right: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Height"),
                                    Text(nf.format(inference.height))
                                  ]
                                ),
                                Slider(
                                  value: inference.height.toDouble(),
                                  max: 1024.0,
                                  min: 64,
                                  divisions: (1024-64)~/64,
                                  onChanged: (double value) {
                                    inference.height = value.toInt();
                                  },

                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 12, right: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Rounds"),
                                    Text(nf.format(inference.rounds))
                                  ]
                                ),
                                Slider(
                                  value: inference.rounds.toDouble(),
                                  max: 80,
                                  min: 1,
                                  divisions: (80-1)~/1,
                                  onChanged: (double value) {
                                    inference.rounds = value.toInt();
                                  },

                                ),
                              ],
                            ),
                          ),
                        ]
                      ),
                    );
                  }),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      controller: _tabController,
                      tabs: const [
                        Tab(text: "Playground"),
                        Tab(text: "Performance metrics"),
                        //Tab(text: "Deploy"),
                      ]
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            TTIPlayground(),
                            TTIPerformanceMetricsPage(),
                            //Container(),
                          ]
                        ),
                      )
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

