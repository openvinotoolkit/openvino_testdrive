// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';
import 'package:inference/pages/download_model/download_model.dart';
import 'package:inference/providers/download_provider.dart';
import 'package:provider/provider.dart';

class DownloadRequestWidget extends StatelessWidget{
  final String id;
  const DownloadRequestWidget({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<DownloadProvider, DownloadRequest?>(
      selector: (_, provider) => provider.downloads[id],
      builder: (context, request, _) {
        if (request == null) {
          return Container();
        }

        return StreamBuilder<DownloadStats>(
          stream: request.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final stats = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: ProgressRing(
                      value: stats.percentage * 100,
                      strokeWidth: 8,
                    ),
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
                    child: Text("Downloading depedencies..."),
                  )
                ]
              );
            }
            return const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: ProgressRing()
              ),
            );
          }
        );
      }
    );
  }

}
