// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/vlm/widgets/assistant_message.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/vlm_inference_provider.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssistantMessage Widget Tests', () {
    late Message testMessage;
    late VLMInferenceProvider inferenceProvider;
    late PublicProject project;
    late Image thumbnail;
    setUp(() {
      thumbnail = Image.asset('images/logo_50.png');
      project = PublicProject("id", "model_id", "app_version", "name",
          "creation_time", ProjectType.vlm, "/path/", thumbnail, null);

      inferenceProvider = VLMInferenceProvider(project, "auto");

      testMessage = Message(
        Speaker.assistant,
        "Test message Test message Test message",
        null,
        DateTime.now(),
        true,
      );
    });

    Widget createTestWidget(Widget child) {
      return FluentApp(
        home: ChangeNotifierProvider<VLMInferenceProvider>.value(
          value: inferenceProvider,
          child: ScaffoldPage(content: child),
        ),
      );
    }

    testWidgets('renders correctly with message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(AssistantMessage(testMessage)));

      expect(
          find.text("Test message Test message Test message"), findsOneWidget);

      // Find all `Container` widgets and pick the first one
      final containerFinder = find.descendant(
        of: find.byType(AssistantMessage),
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      );
      final container = tester.widget<Container>(containerFinder.first);

      final BoxDecoration? decoration = container.decoration as BoxDecoration?;

      expect(decoration, isNotNull, reason: 'BoxDecoration should not be null');
      expect(decoration!.image!.image, isA<AssetImage>());

      final AssetImage image = decoration.image!.image as AssetImage;
      final AssetImage image2 = thumbnail.image as AssetImage;
      expect(image.assetName, equals(image2.assetName));
    });

    testWidgets('copies message to clipboard when copy button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(AssistantMessage(testMessage)));

      final assistantMessageFinder = find.byType(AssistantMessage);
      expect(assistantMessageFinder, findsOneWidget);

      final markdown = find.byType(MarkdownBody);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);

      await gesture.addPointer();
      final center = tester.getCenter(markdown.first);
      await gesture.moveTo(center);

      await tester.pumpAndSettle();

      final clipboardIcon = find.byIcon(FluentIcons.copy);
      await tester.pumpAndSettle();

      expect(clipboardIcon, findsOneWidget);

    });
  });
}
