// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:inference/main.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Download model from HF', (tester) async {
   const app = App();
   await tester.pumpWidget(app);

   await tester.tap(find.text('Import model'));
   await tester.pumpAndSettle();

   await tester.tap(find.text('Hugging Face'));
   await tester.pumpAndSettle();

   final searchBarFinder = find.bySemanticsLabel('Find a model').first;
   await tester.tap(searchBarFinder, warnIfMissed: false);
   await tester.pumpAndSettle();
   await tester.enterText(searchBarFinder, 'tiny');
   await tester.pumpAndSettle();

   await tester.tap(find.text('TinyLlama 1.1B Chat V1.0').first);
   await tester.pumpAndSettle();
   await tester.tap(find.text('Import selected model'));
   await tester.pumpFrames(app, const Duration(seconds: 1));
   expect(find.textContaining(RegExp(r'^[1-9][\d,]* MB$')), findsNWidgets(2));

   await tester.pumpAndSettle();
  });
}
