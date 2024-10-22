import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/router.dart';
import 'package:inference/theme_fluent.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

const String title = 'OpenVINO TestDrive';

void main() async {
  MediaKit.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferenceProvider>(create: (_) => PreferenceProvider("AUTO")),
        ChangeNotifierProvider<ProjectProvider>(create: (_) => ProjectProvider([])),
        ChangeNotifierProvider(create: (_) => AppTheme()),
      ],
      builder: (context, child) {
        final theme = context.watch<AppTheme>();
        return FluentApp.router(
          title: title,
          themeMode: theme.mode,
          debugShowCheckedModeBanner: false,
          color: theme.color,
          theme: FluentThemeData(
            accentColor: theme.color,
            visualDensity: VisualDensity.standard,
            fontFamily: theme.fontFamily,
          ),
          // locale: theme.locale,
          builder: (context, child) => NavigationPaneTheme(
            data: const NavigationPaneThemeData(
              // backgroundColor: theme.windowEffect != flutter_acrylic.WindowEffect.disabled
              //   ? Colors.transparent : null,
            ),
            child: child!,
          ),
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}
