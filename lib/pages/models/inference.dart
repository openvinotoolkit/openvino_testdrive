// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/computer_vision/computer_vision.dart';
import 'package:inference/pages/text_generation/text_generation.dart';
import 'package:inference/pages/text_to_image/text_to_image_page.dart';
import 'package:inference/pages/transcription/transcription.dart';
import 'package:inference/pages/vlm/vlm_page.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/preference_provider.dart';
import 'package:provider/provider.dart';

class InferencePage extends StatefulWidget {
  final Project project;
  const InferencePage(this.project, {super.key});

  @override
  State<InferencePage> createState() => _InferencePageState();
}

class _InferencePageState extends State<InferencePage> {
  late Future<void> deviceFuture;

  Future<void> ensureSupportedDevice() async {
    // make sure it's waiting for build since we're changing the preference provider
    final provider = Provider.of<PreferenceProvider>(context, listen: false);
    await Future.delayed(Duration.zero);
    final selectedDevice = provider.device;
    if (selectedDevice == "NPU" && !widget.project.npuSupported) {
      provider.device = PreferenceProvider.defaultDevice;
      showChangeNotification();
    }
  }

  void showChangeNotification() {
    if (context.mounted) {
      displayInfoBar(context, builder: (context, close) => InfoBar(
        title: const Text('The previously selected device is not supported by this model, switching back to default.'),
        severity: InfoBarSeverity.info,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    deviceFuture = ensureSupportedDevice();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: deviceFuture,
      builder: (context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return switch(widget.project.type){
            ProjectType.image => ComputerVisionPage(widget.project as GetiProject),
            ProjectType.text => TextGenerationPage(widget.project),
            ProjectType.speech => TranscriptionPage(widget.project),
            ProjectType.textToImage => TextToImagePage(widget.project),
            ProjectType.vlm => VLMPage(widget.project),
          };
        } else {
          return Container();
        }
      }
    );
  }
}
