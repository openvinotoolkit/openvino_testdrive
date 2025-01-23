// Copyright (c) 2024 Intel Corporation
//
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:inference/utils.dart';

class DownloadState {
  int received = 0;
  int total = 0;
  bool done = false;
}

class DownloadStats {
  final double percentage;
  final int received;
  final int total;

  const DownloadStats(this.percentage, this.received, this.total);
}

class DownloadRequest {
  Completer<void> done = Completer<void>();
  late final StreamController<DownloadStats> _progressController;
  late final Stream<DownloadStats> stream;

  final String id;
  final Map<String, String> downloads;
  final List<DownloadState> downloadStates = [];
  final Map<String, String> headers;
  Function? onDone;

  final _cancelToken = CancelToken();

  DownloadRequest({required this.id, required this.downloads, this.headers = const {}}) {
    _progressController = StreamController<DownloadStats>();
    stream = _progressController.stream.asBroadcastStream();
  }

  Future<void> start() async {
    final dio = dioClient();

    List<Future> promises = [];
    for (final entry in downloads.entries) {
      final url = entry.key;
      final destination = entry.value;

      final state = DownloadState();
      final promise = dio.download(
        url,
        destination,
        options: Options(headers: headers),
        cancelToken: _cancelToken,
        onReceiveProgress: (int received, int total) {
          if (!_cancelToken.isCancelled) {
            state.received = received;
            state.total = total;
            updateProgress();
          }
        },
      );
      downloadStates.add(state);
      promises.add(promise);
    }

    await Future.wait(promises);
    done.complete();
    _progressController.close();
    onDone?.call();
  }

  void updateProgress() {
    _progressController.add(stats);
  }


  DownloadStats get stats {
    final [received, total] = downloadStates.fold([0, 0], (collector, element) {
        return [collector[0] + element.received, collector[1] + element.total];
    });

    if (received == 0 || total == 0) {
      return DownloadStats(0.0, received, total);
    }

    return DownloadStats(received / total, received, total);
  }
}

class DownloadProvider extends ChangeNotifier {
  final Map<String, DownloadRequest> downloads = {};


  Future<void> requestDownload(DownloadRequest request) async {
    if (downloads.containsKey(request.id)) {
      throw Exception("Other download with id '${request.id}' already in progress");
    }

    downloads[request.id] = request;
    notifyListeners();
    await request.start();
  }
}
