// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

 import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/interop/openvino_bindings.dart';
import 'package:inference/pages/computer_vision/providers/batch_inference_provider.dart';
import 'package:inference/pages/computer_vision/widgets/folder_selector.dart';
import 'package:inference/widgets/horizontal_rule.dart';
import 'package:inference/pages/computer_vision/widgets/model_properties.dart';
import 'package:inference/pages/computer_vision/widgets/output_selector.dart';
import 'package:inference/pages/computer_vision/widgets/device_selector.dart';
import 'package:inference/providers/image_inference_provider.dart';
import 'package:provider/provider.dart';

class BatchInference extends StatelessWidget {
  const BatchInference({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<ImageInferenceProvider, BatchInferenceProvider>(
      lazy: false,
      update: (_, imageInference, batchInferenceProvider) {
        if (batchInferenceProvider != null) {
          if (batchInferenceProvider.imageInference != imageInference) {
            batchInferenceProvider.imageInference = imageInference;
          }
          return batchInferenceProvider;
        }
        return BatchInferenceProvider(imageInference, SerializationOutput(overlay: true));
      },
      create: (BuildContext context) {
        return BatchInferenceProvider(context.read<ImageInferenceProvider>(), SerializationOutput(overlay: true));
      },
      child: Consumer<BatchInferenceProvider>(builder: (context, batchInference, child) {
          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 720,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FolderSelector(
                            label: "Source folder",
                            onSubmit: (v) => batchInference.sourceFolder = v,
                          ),
                          const HorizontalRule(),
                          FolderSelector(
                            label: "Destination folder",
                            onSubmit: (v) => batchInference.destinationFolder = v,
                          ),
                          const HorizontalRule(),
                          const OutputSelector(),
                          const HorizontalRule(),
                          DeviceSelector(npuSupported: batchInference.imageInference.project.npuSupported),
                          const HorizontalRule(),
                          Row(
                            children: [
                              FilledButton(
                                onPressed: () {
                                  if (batchInference.state == BatchInferenceState.running) {
                                    batchInference.stop();
                                  } else {
                                    batchInference.start();
                                  }

                                },
                                child: Builder(
                                  builder: (context) {
                                    String text = switch(batchInference.state) {
                                      BatchInferenceState.ready => "Start batch inference",
                                      BatchInferenceState.running => "Stop",
                                      BatchInferenceState.done => "Start batch inference",
                                    };
                                    return Text(text);
                                  }
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  if (batchInference.progress == null) {
                                    return Container();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: ProgressBar(value: batchInference.progress!.percentage() * 100),
                                  );
                                }
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ModelProperties(project: batchInference.imageInference.project),
            ],
          );
        }
      ),
    );
  }
}
