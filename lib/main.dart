import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/config.dart';
import 'package:inference/router.dart';
import 'package:inference/theme_fluent.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';


const String title = 'OpenVINO TestDrive';

void testConnection() async {
  final dio = Dio(BaseOptions(connectTimeout: Duration(seconds: 10)));
  
  try {
    await dio.get(collections[0].path);
  } on DioException catch(ex) {
    if (ex.type == DioExceptionType.connectionError) {
      // Perhaps proxy issue, disable proxy in future requests.
      Config.proxyDirect = true;
    }
  }
}

void main() {
  MediaKit.ensureInitialized();
  testConnection();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PreferenceProvider>(create: (_) => PreferenceProvider(PreferenceProvider.defaultDevice)),
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
            scaffoldBackgroundColor: const Color(0x80FFFFFF),
            visualDensity: VisualDensity.standard,
            fontFamily: theme.fontFamily,
          ),
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF2C2C2C),
            accentColor: theme.darkColor,
            cardColor: const Color(0xFF383838),
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
