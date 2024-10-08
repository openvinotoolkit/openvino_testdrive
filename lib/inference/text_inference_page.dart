import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/inference/text/performance_metrics.dart';
import 'package:inference/inference/text/playground.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:inference/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TextInferencePage extends StatefulWidget {
  final Project project;
  const TextInferencePage(this.project, {super.key});

  @override
  State<TextInferencePage> createState() => _TextInferencePageState();
}

class _TextInferencePageState extends State<TextInferencePage> with TickerProviderStateMixin {

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

    return ChangeNotifierProxyProvider<PreferenceProvider, TextInferenceProvider>(
      create: (_) {
        return TextInferenceProvider(widget.project, null);
      },
      update: (_, preferences, textInferenceProvider) {
        if (textInferenceProvider == null) {
          return TextInferenceProvider(widget.project, preferences.device);
        }
        if (!textInferenceProvider.sameProps(widget.project, preferences.device)) {
          return TextInferenceProvider(widget.project, preferences.device);
        }
        return textInferenceProvider;
      },
      child: Scaffold(
        appBar: const Header(true),
        body: Padding(
          padding: const EdgeInsets.only(left: 58, right: 58, bottom: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<TextInferenceProvider>(
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
                                    const Text("Temperature"),
                                    Text(nf.format(inference.temperature))
                                  ]
                                ),
                                Slider(
                                  value: inference.temperature,
                                  max: 2.0,
                                  onChanged: (double value) {
                                    inference.temperature = value;
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
                                    const Text("Top P"),
                                    Text(nf.format(inference.topP))
                                  ]
                                ),
                                Slider(
                                  value: inference.topP,
                                  max: 1.0,
                                  onChanged: (double value) {
                                    inference.topP = value;
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
                          children: [
                            const Playground(),
                            const PerformanceMetricsPage(),
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

