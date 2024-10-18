import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:inference/header.dart';
import 'package:inference/inference/device_selector.dart';
import 'package:inference/inference/model_info.dart';
import 'package:inference/project.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:inference/providers/project_provider.dart';
import 'package:inference/public_models.dart';
import 'package:inference/theme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String formatBytes(int bytes) {
  return "${NumberFormat("#,##0").format(bytes / pow(1024, 2))} MB";
}

class DownloadPage extends StatefulWidget {
  final PublicProject project;
  final Function() onDone;
  const DownloadPage(this.project, {required this.onDone, super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  void initState() {
    super.initState();

    startDownload();
  }

  void startDownload() async {
    final downloadProvider = Provider.of<DownloadProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);

    final files = downloadFiles(widget.project);

    try {
      await downloadProvider.queue(files, widget.project.modelInfo?.collection.token);
      await getAdditionalModelInfo(widget.project);
      projectProvider.completeLoading(widget.project);
      widget.onDone();
    } catch(e) {
      if (mounted) {
        showDialog(context: context, builder: (BuildContext context) => AlertDialog(
              title: Text('An error occured trying to download ${widget.project.name}'),
              content: Text(e.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Close'),
                ),
              ]
            ),

        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(true),
      body: Padding(
        padding: const EdgeInsets.only(left: 58, right: 58, bottom: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 250,
              child: ModelInfo(widget.project),
            ),
            Consumer<DownloadProvider>(builder: (context, downloads, child) {
              final stats = downloads.stats;
              return Expanded(
                child: Column(
                  children: [
                    const DeviceSelector(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            backgroundColor: textColor,
                            value: stats.percentage
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })
          ],
        ),
      ),
    );
  }
}
