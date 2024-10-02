import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:inference/sized_and_translated.dart';

class Debouncer {
  Debouncer(this.duration);
  Duration duration;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }
}

class EasyNotifier extends ChangeNotifier {
  void notify([VoidCallback? action]) {
    action?.call();
    notifyListeners();
  }
}

class TranslationData extends EasyNotifier {
  Offset _offset = Offset.zero;
  set offset(Offset value) => notify(() => _offset = value);
  Offset get offset => _offset;

  Size _size = const Size(100, 100);
  set size(Size value) => notify(() => _size = value);
  Size get size => _size;
}

class ZoomableImage extends StatefulWidget {
  final Image image;
  const ZoomableImage(this.image, {super.key});

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}


class _ZoomableImageState extends State<ZoomableImage> {
  final Debouncer _zoomDebounce = Debouncer(const Duration(milliseconds: 350));
  TranslationData data = TranslationData();


  void handleZoom(double delta) {
    data.size *= 1 + delta;
    print("new size: " + data.size.toString());
    // TODO clamp to  min and max size
  }

  void handleDrag(DragUpdateDetails details) {
    data.offset += details.delta;
    print(data.offset);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: data,
      builder: (BuildContext context, Widget? child) {
        return Listener(
          onPointerSignal: (signal) {
            if (signal is PointerScrollEvent) {
              print(signal);
              double dir = signal.scrollDelta.dy > 0 ? -1 : 1;
              handleZoom(dir * .1);
              //_zoomDebounce.run(() => widget.onDragEnded.call());
            }
          },
          child: SizedAndTranslated(
            offset: data.offset,
            size: data.size,
            child: GestureDetector(
              onPanUpdate: handleDrag,
              child: widget.image,
            ),
          ),
        );
      }
    );
  }
}
