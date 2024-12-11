import 'package:av_media_player/player.dart';
import 'package:av_media_player/widget.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

class AVPlayer extends AbstractPlayer {
  final AvMediaPlayer player;

  AVPlayer(this.player) {
    _initialize();
  }

  void _initialize() {
    state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: Duration(milliseconds: player.position.value),
        duration: duration(),
        buffering: true, // video starts as buffering
        width: player.videoSize.value.width.toInt(),
        height: player.videoSize.value.height.toInt(),
        volume: player.volume.value,
        subtitle: [],
      );
      player.position.addListener(_listener);
  }

  void _listener() {
    bool isBuffering = false;
    state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: position(),
        duration: duration(),
        buffering: isBuffering,
        width: player.videoSize.value.width.toInt(),
        height: player.videoSize.value.height.toInt(),
        volume: player.volume.value,
        subtitle: [],
    );

    if (!playingController.isClosed) {
      playingController.add(isPlaying);
    }

    if (!completedController.isClosed) {
      completedController.add(isCompleted);
    }

    if (!bufferingController.isClosed) {
      bufferingController.add(isBuffering);
    }

    if (!positionController.isClosed) {
      positionController.add(position());
    }

    if (!durationController.isClosed) {
      durationController.add(duration()!);
    }

    if (!widthController.isClosed) {
      widthController.add(player.videoSize.value.width.toInt());
    }

    if (!heightController.isClosed) {
      heightController.add(player.videoSize.value.height.toInt());
    }

    if (!volumeController.isClosed) {
      volumeController.add(player.volume.value);
    }

    //if (!subtitleController.isClosed) {
    //  subtitleController.add([]);
    //}
    //if (!bufferController.isClosed) {
    //  if (controller.value.buffered.lastOrNull?.end != null) {
    //    bufferController.add(controller.value.buffered.lastOrNull!.end);
    //  }
    //}
  }

  bool get isPlaying => player.playbackState.value == PlaybackState.playing;
  bool get isCompleted => player.playbackState.value == PlaybackState.closed;

  Duration? duration() {
    if (player.mediaInfo.value != null) {
      return Duration(milliseconds: player.mediaInfo.value!.duration);
    }
    return null;
  }

  Duration position() {
    return Duration(milliseconds: player.position.value);
  }


  void setSource(String source) {
    player.open(source);
  }

  @override
  Future<void> pause() async {
    player.pause();
  }

  @override
  Future<void> play() async {
    player.play();
  }

  @override
  Future<void> playOrPause() async {
    if (isPlaying) {
      player.pause();
    } else {
      player.play();
    }
  }

  @override
  Future<void> seek(Duration duration) async {
    // TODO: implement seek
    print(duration.inMilliseconds);
    player.seekTo(duration.inMilliseconds);
  }

  @override
  Future<void> setRate(double rate) {
    // TODO: implement setRate
    throw UnimplementedError();
  }

  @override
  void setSubtitle(String subtitle) {
    // TODO: implement setSubtitle
  }

  @override
  Future<void> setVolume(double volume) async {
    player.setVolume(volume);
  }

  @override
  Widget videoWidget() {
    // TODO: implement videoWidget
    return AvMediaView(
      initPlayer: player,
      //initLooping: false,
      //initAutoPlay: true,
      onCreated: (player) {
        player.loading.addListener(
          () => print("loaded")
        );
      }
    );
  }

}
