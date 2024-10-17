import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/landing/landing_page.dart';

const bool isDesktop = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    //return MultiProvider(
    //  providers: [
    //    ChangeNotifierProvider<PreferenceProvider>(create: (_) => PreferenceProvider("AUTO")),
    //    ChangeNotifierProvider<ProjectProvider>(create: (_) => ProjectProvider([])),
    //  ],
    //  child: const OpenVINOTestDriveApp(),
    //);
    return FluentApp(
      theme: FluentThemeData(
        fontFamily: "IntelOne",
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
      ),
      home: NavigationView(
        appBar: const NavigationAppBar(
          title: Text("OpenVINO TestDrive"),
        ),
        pane: NavigationPane(
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text("Home"),
                body: const LandingPage(),
            ),
            PaneItem(
                icon: Icon(FluentIcons.insert),
                title: Text("Insert"),
                body: Text("Insert long"),
            ),
            PaneItem(
                icon: Icon(FluentIcons.view),
                title: Text("View"),
                body: Text("View long"),
            )
          ]
        ),
      ),
    );
  }
}
