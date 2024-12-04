import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/pages/import/huggingface.dart';
import 'package:inference/pages/import/widgets/import_geti_model_dialog.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  _ImportPageState createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final updatedTheme = theme.copyWith(
        navigationPaneTheme: theme.navigationPaneTheme.merge(NavigationPaneThemeData(
            backgroundColor: theme.scaffoldBackgroundColor,
        ))
    );

    return FluentTheme(
      data: updatedTheme,
      child: NavigationView(
        pane: NavigationPane(
          size: const NavigationPaneSize(topHeight: 64),
          header: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text("Import model",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          selected: selected,
          onChanged: (i) => setState(() {selected = i;}),
          displayMode: PaneDisplayMode.top,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.processing),
              title: const Text("Huggingface"),
              body: const  Huggingface(),
            ),
            PaneItemAction(
              icon: const Icon(FluentIcons.project_collection),
              title: const Text("Local disk"),
              onTap: () => showImportGetiModelDialog(context,
                callback: (projects) {
                  if (projects != null && projects.isNotEmpty) {
                    if (projects.length == 1) {
                      GoRouter.of(context).go("/models/inference", extra: projects.first);
                    } else {
                      GoRouter.of(context).pop();
                    }
                  }
                }
              ),
            ),
          ],
        )
      ),
    );
  }
}
