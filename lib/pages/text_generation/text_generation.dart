
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/text_generation/playground.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/text_inference_provider.dart';
import 'package:provider/provider.dart';

class TextGenerationPage extends StatefulWidget {
  final Project project;
  const TextGenerationPage(this.project, {super.key});

  @override
  State<TextGenerationPage> createState() => _TextGenerationPageState();
}

class _TextGenerationPageState extends State<TextGenerationPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
        ))
    );

    return ChangeNotifierProxyProvider<PreferenceProvider, TextInferenceProvider>(
      create: (_) {
        return TextInferenceProvider(widget.project, null);
      },
      update: (_, preferences, textInferenceProvider) {
        final init = textInferenceProvider == null ||
          !textInferenceProvider.sameProps(widget.project, preferences.device);
        if (init) {
          final textInferenceProvider = TextInferenceProvider(widget.project, preferences.device);
          textInferenceProvider.loadModel().catchError((e) {
            // TODO: Error handling
            print(e);
          });
          return textInferenceProvider;
        }
        if (!textInferenceProvider.sameProps(widget.project, preferences.device)) {
          return TextInferenceProvider(widget.project, preferences.device);
        }
        return textInferenceProvider;
      },
      child: Stack(
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
                  selected: selected,
                  onChanged: (i) => setState(() {selected = i;}),
                  displayMode: PaneDisplayMode.top,
                  items: [
                    PaneItem(
                      icon: const Icon(FluentIcons.game),
                      title: const Text("Playground"),
                      body: Playground(project: widget.project),
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
                      child: OutlinedButton(
                        style: ButtonStyle(
                          shape:WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side:  const BorderSide(color: Color(0XFF545454)),
                          )),
                        ),
                        child: const Text("Close"),
                        onPressed: () =>  GoRouter.of(context).canPop()
                          ? GoRouter.of(context).pop()
                          : GoRouter.of(context).go('/models'),
                      ),
                    ),
                  ]
                ),
              ),
            )
          ],
        ),
    );
  }
}