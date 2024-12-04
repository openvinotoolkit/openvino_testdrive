import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/import/huggingface.dart';

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
          //customPane: CustomNavigationPane(),
          selected: selected,
          onChanged: (i) => setState(() {selected = i;}),
          displayMode: PaneDisplayMode.top,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.processing),
              title: const Text("Huggingface"),
              body: const  Huggingface(),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.project_collection),
              title: const Text("Local disk"),
              body: Container(),
            ),
          ],
        )
      ),
    );
  }
}
