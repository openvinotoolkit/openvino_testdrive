import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:video_player_win/video_player_win.dart';

class WinVideoPlayerWrapper extends StatefulWidget {
  final String file;
  final Function(Duration)? onPosition;
  const WinVideoPlayerWrapper({super.key, required this.file, this.onPosition});

  @override
  State<WinVideoPlayerWrapper> createState() => _WinVideoPlayerWrapperState();
}

class _WinVideoPlayerWrapperState extends State<WinVideoPlayerWrapper> {
  late WinVideoPlayerController controller;

  void positionListener() {
    widget.onPosition?.call(controller.value.position);
  }

  @override
  void initState() {
    super.initState();
    controller = WinVideoPlayerController.file(File(widget.file));
    controller.initialize().then((_) {
      if (controller.value.isInitialized) {
        controller.play();
        controller.setVolume(0);
        setState(() {});
        controller.addListener(positionListener);
      } else {
        print("video file load failed");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WinVideoPlayer(controller);
  }
}
