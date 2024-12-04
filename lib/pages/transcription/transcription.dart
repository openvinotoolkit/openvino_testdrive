import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/pages/transcription/performance_metrics.dart';
import 'package:inference/pages/transcription/playground.dart';
import 'package:inference/utils.dart';
import 'package:provider/provider.dart';

class TranscriptionPage extends StatefulWidget {
  final Project project;
  const TranscriptionPage(this.project, {super.key});

  @override
  State<TranscriptionPage> createState() => _TranscriptionPageState();
}

class _TranscriptionPageState extends State<TranscriptionPage> {


  int selected = 0;
  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
        ))
    );
    return ChangeNotifierProxyProvider<PreferenceProvider, SpeechInferenceProvider>(
      lazy: false,
      create: (_) {
        final device = Provider.of<PreferenceProvider>(context, listen: false).device;
        return SpeechInferenceProvider(widget.project, device);
      },
      update: (_, preferences, imageInferenceProvider) {
        if (imageInferenceProvider != null && imageInferenceProvider.sameProps(widget.project, preferences.device)) {
          return imageInferenceProvider;
        }
        return SpeechInferenceProvider(widget.project, preferences.device);
      },
      child:  Stack(
        children: [
          FluentTheme(
            data: updatedTheme,
            child: NavigationView(
              pane: NavigationPane(
                size: const NavigationPaneSize(topHeight: 64),
                header: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: widget.project.thumbnailImage(),
                                fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(widget.project.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                //customPane: CustomNavigationPane(),
                selected: selected,
                onChanged: (i) => setState(() {selected = i;}),
                displayMode: PaneDisplayMode.top,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.processing),
                    title: const Text("Playground"),
                    body: Playground(project: widget.project),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.line_chart),
                    title: const Text("Performance metrics"),
                    body: PerformanceMetrics(project: widget.project),
                  ),
                ],
              )
            ),
          ),
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: FilledButton(
                      child: const Text("Download"),
                      onPressed: () => downloadProject(widget.project),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: OutlinedButton(
                      style: ButtonStyle(
                        shape:WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          side:  const BorderSide(color: Color(0XFF545454)),
                        )),
                      ),
                      child: const Text("Close"),
                      onPressed: () =>  GoRouter.of(context).go("/models"),
                    ),
                  ),
                ]
              ),
            ),
          )
        ],
      )
    );
  }
}
