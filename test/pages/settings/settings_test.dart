import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/config.dart';
import 'package:inference/pages/settings/settings.dart';
import 'package:inference/theme_fluent.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:provider/provider.dart';

import '../../mocks.dart';
import '../../utils.dart';


void main() {
  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() async {
    await deleteConfigFile();
  });

  testWidgets('SettingsPage displays and updates theme mode', (WidgetTester tester) async {
    final appTheme = AppTheme();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppTheme>(
        create: (_) => appTheme,
        child: const FluentApp(
          home: SettingsPage(),
        ),
      ),
    );

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Select the color theme for the application.'), findsOneWidget);

    await tester.tap(find.byType(ComboBox<ThemeMode>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark').first);
    await tester.pumpAndSettle();

    expect(appTheme.mode, ThemeMode.dark);
  });

  testWidgets('SettingsPage displays and updates proxy settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppTheme>(create: (_) => AppTheme()),
        ],
        child: const FluentApp(
          home: SettingsPage(),
        ),
      ),
    );

    expect(find.text('HTTPS Proxy'), findsOneWidget);
    expect(find.text('Configure the proxy settings for network connections. Leave empty to auto-configure.'), findsOneWidget);

    await tester.tap(find.byType(ToggleSwitch));
    await tester.pumpAndSettle();

    expect(Config.proxyEnabled, true);

    await tester.enterText(find.byType(TextBox), 'http://proxy.example.com:8080');
    await tester.pumpAndSettle();

    expect(Config.proxy, 'http://proxy.example.com:8080');
  });
}
