import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:inference/deployment_processor.dart';
import 'package:inference/project.dart';
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

class DownloadProvider extends ChangeNotifier {
  final Map<String, DownloadState> _downloads = {};

  CancelToken? _cancelToken;
  Function? onCancel;
  DownloadProvider();

  Future<void> queue(Map<String, String> downloads, String? token) async{
    List<Future> promises = [];

    final dio = dioClient();
    _cancelToken = CancelToken();
    for (final url in downloads.keys) {
      print("downloading: $url");
      final state = DownloadState();
      _downloads[url] = state;
      final destination = downloads[url];
      Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
      final promise = dio.download(url, destination,
        cancelToken: _cancelToken,
        options: Options(headers: headers),
        onReceiveProgress: (int received, int total) {
          if (!_cancelToken!.isCancelled) {
            state.received = received;
            state.total = total;
            notifyListeners();
          }
        },
      ).catchError((e) {
        if (e is DioException && e.type == DioExceptionType.cancel) {
          print("Download cancelled: $url");
          return Response(requestOptions: RequestOptions(path: url));
        } else {
          _cancelToken?.cancel();
          throw e;
        }
      }).then((_) => state.done);
      promises.add(promise);
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
    onCancel?.call();
  }

  @override
  void dispose() {
    if (_downloads.isNotEmpty) {
      cancel();
    }
    super.dispose();
  }
}
