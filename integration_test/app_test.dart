import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Download model from HF', (tester) async {
    final originalOnError = FlutterError.onError!;

    const app = App();
    await tester.pumpWidget(app);

    FlutterError.onError =  originalOnError;

    await tester.tap(find.text('Import Model'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Huggingface'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Search by name'));
    await tester.pumpAndSettle();
    await tester.enterText(find.bySemanticsLabel('Search by name'), 'tiny');
    await tester.pumpAndSettle();

    await tester.tap(find.text('TinyLlama-1.1B-Chat-v1.0-int4-ov'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add model'));
    await tester.pumpFrames(app, const Duration(seconds: 1));
    expect(find.textContaining(RegExp(r'^[1-9]\d* MB$')), findsNWidgets(2));
  });
}