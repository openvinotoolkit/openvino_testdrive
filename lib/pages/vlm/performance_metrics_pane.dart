// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/vlm/providers/vlm_inference_provider.dart';
import 'package:inference/pages/vlm/widgets/vlm_metrics_grid.dart';
import 'package:provider/provider.dart';

class VLMPerformanceMetricsPane extends StatefulWidget {
  const VLMPerformanceMetricsPane({super.key});

  @override
  State<VLMPerformanceMetricsPane> createState() => _VLMPerformanceMetricsPaneState();
}

class _VLMPerformanceMetricsPaneState extends State<VLMPerformanceMetricsPane> {

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<VLMInferenceProvider>(context, listen: false);
    if (provider.metrics == null) {
      provider.loaded.future.then((_) {
          provider.message("Generate OpenVINO logo");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VLMInferenceProvider>(builder: (context, inference, child) {
        if (inference.metrics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/intel-loading.gif', width: 100),
                const Text("Running benchmark prompt...")
              ],
            )
          );
        }

        final metrics = inference.metrics!;

        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VLMMetricsGrid(metrics: metrics),
              ],
            ),
          ),
        );
    });
  }
}


