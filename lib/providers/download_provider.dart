import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/project.dart';

final dio = Dio();

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

class DownloadProvider extends ChangeNotifier {
  final Project? project;
  final Map<String, DownloadState> _downloads = {};

  CancelToken? _cancelToken;
  DownloadProvider(this.project);

  Future<void> queue(Map<String, String> downloads) async{
    List<Future<Response>> promises = [];

    _cancelToken = CancelToken();
    for (final url in downloads.keys) {
      print("downloading: $url");
      final state = DownloadState();
      _downloads[url] = state;
      final destination = downloads[url];
      final promise = dio.download(url, destination, cancelToken: _cancelToken, onReceiveProgress: (int received, int total) {
          if (!_cancelToken!.isCancelled) {
            state.received = received;
            state.total = total;
            notifyListeners();
          }
      });
      promise.catchError((e) => _cancelToken!.cancel(e.toString()));
      promise.then((_) => state.done);
      promises.add(promise);
      state.done;
    }

    await Future.wait(promises, eagerError: true) ;
    _downloads.clear();
    notifyListeners();
  }

  DownloadStats get stats {
    final [received, total] = _downloads.values.fold([0, 0], (collector, element) {
        return [collector[0] + element.received, collector[1] + element.total];
    });

    if (received == 0 || total == 0) {
      return DownloadStats(0.0, received, total);
    }

    return DownloadStats(received / total, received, total);
  }

  double get percentageComplete {
    final [received, total] = _downloads.values.fold([0, 0], (collector, element) {
        return [collector[0] + element.received, collector[1] + element.total];
    });
    if (received == 0 || total == 0) {
      return 0.0;
    }
    return received / total;
  }

  void cancel() {
    _cancelToken?.cancel();
    deleteProjectData(project!);
  }

  @override
  void dispose() {
    if (_downloads.isNotEmpty) {
      cancel();
    }
    super.dispose();
  }
}
