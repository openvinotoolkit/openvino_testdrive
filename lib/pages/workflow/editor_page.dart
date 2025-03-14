// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/workflow/utils/assets.dart';
import 'package:inference/pages/workflow/widgets/editor.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:provider/provider.dart';

class WorkflowEditorPage extends StatefulWidget {
  const WorkflowEditorPage({super.key});

  @override
  State<WorkflowEditorPage> createState() => _WorkflowEditorPageState();
}


class _WorkflowEditorPageState extends State<WorkflowEditorPage> {

  Future<WorkflowEditorAssets>? assetFetcher;


  @override
  void initState() {
    super.initState();

    final projectsProvider = Provider.of<ProjectProvider>(context, listen: false);
    assetFetcher = WorkflowEditorAssets.load(
      icons: [
        "images/workflow/image.svg" ,
        "images/workflow/clipboard.svg" ,
        "images/workflow/flowchart.svg" ,
      ],
      projectsProvider: projectsProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: assetFetcher,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return WorkflowEditor(assets: snapshot.requireData);
        }
        return Container();
      }
    );
  }
}

