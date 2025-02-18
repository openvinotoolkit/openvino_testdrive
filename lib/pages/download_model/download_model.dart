// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:inference/theme_fluent.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String formatBytes(int bytes) {
  return "${NumberFormat("#,##0").format(bytes / pow(1024, 2))} MB";
}

class DownloadPage extends StatefulWidget {
  final PublicProject project;
  const DownloadPage({super.key, required this.project});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  DownloadRequest? request;

  @override
  void initState() {
    super.initState();
    startDownload();
  }

  void onComplete() {
    print("on complete!");
    if (context.mounted) {
      print("going to model...");
      GoRouter.of(context).go("/models/inference", extra: widget.project);
    }
  }

  void startDownload() async {
    final router = GoRouter.of(context);
    final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    if (downloadProvider.downloads.containsKey(widget.project.id)) {
      request = downloadProvider.downloads[widget.project.id]!;
      if (request!.done.isCompleted) {
        Future.delayed(Duration.zero, () {
          router.go("/models/inference", extra: widget.project);
        });
      } else {
        request!.onDone = onComplete;
      }
      return;
    }

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    Map<String, String> files = {};

    try {
      files = await listDownloadFiles(widget.project);
    } catch (e) {
      if (mounted){
        await showDialog(context: context, builder: (BuildContext context) => ContentDialog(
          title: const Text('Model was not found'),
          actions: [
            Button(
              onPressed: () {
                router.canPop() ? router.pop() : router.go('/home');
              },
              child: const Text('Close'),
            ),
          ],
        ));
      }
      return;
    }

    try {
      request = DownloadRequest(
        id: widget.project.id,
        downloads: files,
      )..onDone = onComplete;
      setState(() {});
      projectProvider.addProject(widget.project);
      await getAdditionalModelInfo(widget.project);
      downloadProvider.requestDownload(request!);
    } catch(e) {
      print(e);
      if (mounted) {
        await showDialog(context: context, builder: (BuildContext context) => ContentDialog(
          title: Text('An error occurred trying to download ${widget.project.name}'),
          content: Text(e.toString()),
          actions: [
            Button(
              onPressed: () {
                router.canPop() ? router.pop() : router.go('/home');
              },
              child: const Text('Close'),
            ),
          ],
        ));
      }
    }
  }

  Future<void> onClose() async {
    final navigator = Navigator.of(context);
    final result = await showDialog<bool>(context: context, builder: (BuildContext context) => ContentDialog(
        title: const Text("Download in progress"),
        content: const Text("Downloading will continue in background"),
        actions: <Widget>[
          FilledButton(
            onPressed: () => context.pop(false),
            child: const Text('Continue'),
          ),
          Button(
            onPressed: () => context.pop(true),
            child: const Text('Go back'),
          ),
        ]
      )
    );

    if (result == true && context.mounted) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
      header: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: theme.resources.controlStrokeColorDefault,
                  width: 1.0
              )
          )
        ),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: widget.project.thumbnailImage(),
                            fit: BoxFit.fitWidth),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(widget.project.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Button(
              onPressed: onClose,
              child: const Text("Close")
            ),
          ],
        ),
      ),
      content: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<DownloadStats>(
                    stream: request?.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final stats = snapshot.data!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProgressRing(
                              value: stats.percentage * 100,
                              strokeWidth: 8,
                            ),
                            SizedBox(
                              width: 140,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(formatBytes(stats.received), textAlign: TextAlign.end,),
                                    const Text("/"),
                                    Text(formatBytes(stats.total))
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Downloading model weights"),
                            )
                          ]
                        );
                      }
                      return const ProgressRing();
                    }
                  ),
                )
              ],
            ),
          ),
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.resources.controlStrokeColorDefault,
                  width: 1.0,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    child: Text("Model parameters", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text("Model name", style: TextStyle(fontSize: 14),),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 4),
                    child: Text(widget.project.modelId, style: const TextStyle(fontSize: 14, color: foreground3Color),),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 16),
                    child: Text("Task", style: TextStyle(fontSize: 14),),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 4),
                    child: Text(widget.project.taskName(), style: const TextStyle(fontSize: 14, color: foreground3Color),),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}
