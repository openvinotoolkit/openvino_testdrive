// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inference/pages/workflow/widgets/editor.dart';

class WorkflowEditorPage extends StatefulWidget {
  const WorkflowEditorPage({super.key});

  @override
  State<WorkflowEditorPage> createState() => _WorkflowEditorPageState();
}

class _WorkflowEditorPageState extends State<WorkflowEditorPage> {

  Future<Map<String, PictureInfo>>? iconFetcher;

  Future<Map<String, PictureInfo>> fetchIcons(List<String> paths) async {
    final icons = await Future.wait(paths.map((path) async {
        return MapEntry<String, PictureInfo>(
          path,
          await vg.loadPicture(SvgPicture.asset(path).bytesLoader, null)
        );
    }));
    return Map.fromEntries(icons);
  }

  @override
  void initState() {
    super.initState();
    iconFetcher = fetchIcons([
       "images/workflow/image.svg" ,
       "images/workflow/clipboard.svg" ,
       "images/workflow/flowchart.svg" ,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: iconFetcher,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return WorkflowEditor(icons: snapshot.requireData);
        }
        return Container();
      }
    );
  }
}
