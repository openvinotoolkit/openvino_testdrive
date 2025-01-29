// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/text_generation/utils/user_file.dart';
import 'package:inference/pages/text_generation/widgets/user_file_widget.dart';

void main() {
  testWidgets('UserFileWidget shows filename', (WidgetTester tester) async {
    final userFile = UserFile.fromPath("/some/path/to/file.pdf");

    await tester.pumpWidget(
      FluentApp(
        home: UserFileWidget(file: userFile),
      ),
    );

    expect(find.text('file.pdf'), findsOneWidget);
  });

  testWidgets('UserFileWidget shows tooltip and border on error', (WidgetTester tester) async {
    final userFile = UserFile.fromPath("/some/path/to/file.pdf")
      ..error = "This is an example error";

    const testKey = Key('UserFile');

    await tester.pumpWidget(
      FluentApp(
        home: Center(
          child: UserFileWidget(file: userFile, key: testKey)
        ),
      ),
    );

    final container = find.descendant(
      of: find.byKey(testKey),
      matching: find.byType(Container)
    );
    expect(((tester.firstWidget(container) as Container).decoration
    as BoxDecoration).border?.top.color, Colors.red);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    final center = tester.getCenter(container.first);
    await gesture.moveTo(center);

    await tester.pumpAndSettle();
    final tooltip = find.byType(Tooltip);
    await tester.pumpAndSettle();
    expect(tooltip, findsOneWidget);
    expect(find.text(userFile.error!), findsOneWidget);
  });

  testWidgets('UserFileWidget allows delete', (WidgetTester tester) async {
    final userFile = UserFile.fromPath("/some/path/to/file.pdf");

    bool callbackCalled = false;
    void testCallback() {
      callbackCalled = true;
    }

    await tester.pumpWidget(
      FluentApp(
        home: UserFileWidget(file: userFile, onDelete: testCallback),
      ),
    );

    await tester.tap(find.byType(IconButton));

    expect(callbackCalled, true);
  });
}
