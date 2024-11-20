import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/interop/device.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:inference/widgets/device_selector.dart';
import 'package:provider/provider.dart';


Widget renderWidget(PreferenceProvider preferences) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: preferences,
      ),
    ],
    child: FluentApp(
      home: const ScaffoldPage(
        content: const DeviceSelector(),
      )
    ),
  );
}

PreferenceProvider setup() {
    final preferences = PreferenceProvider("AUTO");
    PreferenceProvider.availableDevices = const [Device("AUTO","auto"), Device("GPU1", "some GPU")];
    return preferences;
}


void main() {
  testWidgets("Device selector shows available devices", (tester) async {
    final preferences = setup();
    await tester.pumpWidget(renderWidget(preferences));

    await tester.tap(find.text("Device: auto"));

    await tester.pumpAndSettle();

    expect(find.text("auto"), findsOneWidget);
    expect(find.text("some GPU"), findsOneWidget);
  });

  testWidgets("Device selector sets device in preferences devices", (tester) async {
    final preferences = setup();
    await tester.pumpWidget(renderWidget(preferences));

    await tester.tap(find.text("Device: auto"));

    await tester.pumpAndSettle();

    final device = PreferenceProvider.availableDevices[1];
    await tester.tap(find.text(device.name));

    expect(preferences.device, device.id);

    await tester.pumpAndSettle();
    expect(find.text("Device: ${device.name}"), findsOneWidget);
  });
}
