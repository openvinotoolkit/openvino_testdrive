// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/models/widgets/model_card.dart';
import 'package:inference/project.dart';

import '../../../fixtures.dart';

Widget modelWidget(Project project) {
  return FluentApp(
    home: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 304,
        ),
        child: ModelCard(project: project)),
    )
  );
}

String? fromRichTextToPlainText(final Widget widget) {
  if (widget is RichText) {
    if (widget.text is TextSpan) {
      final buffer = StringBuffer();
      (widget.text as TextSpan).computeToPlainText(buffer);
      return buffer.toString();
    }
  }
  return null;
}



void main() {
  testWidgets("Test model card shows project info", (tester) async {
    final project = largeLanguageModel();
    await tester.pumpWidget(modelWidget(project));

    expect(find.byWidgetPredicate((widget) => fromRichTextToPlainText(widget)?.contains(project.taskName()) ?? false), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => fromRichTextToPlainText(widget)?.contains(project.architecture) ?? false), findsOneWidget);
  });
}
