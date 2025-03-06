// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:provider/provider.dart';

import '../../fixtures.dart';


Widget testWidget(ImageInferenceProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: provider,
      ),
    ],
    child: FluentApp(
      home: Center(
        child: ModelProperties(project: provider.project)
      ),
    ),
  );
}

void main() {
  testWidgets("Test model properties show model info", (tester) async {
    final model = getiProject();
    final provider = ImageInferenceProvider(model, "CPU");
    await tester.pumpWidget(testWidget(provider));
    expect(find.text(model.name), findsOneWidget);
    expect(find.text(model.taskName()), findsOneWidget);
    expect(find.text(model.architecture), findsOneWidget);
  });
}
