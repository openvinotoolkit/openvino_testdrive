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
        playing: true,
        completed: isCompleted,
        position: Duration(milliseconds: player.position.value),
        duration: duration(),
        buffering: isBuffering, // video starts as buffering
        width: player.videoSize.value.width.toInt(),
        height: player.videoSize.value.height.toInt(),
        volume: player.volume.value,
        subtitle: [],
      );

    player.position.addListener(_positionListener);
    player.volume.addListener(_volumeListener);
    player.videoSize.addListener(_sizeListener);
    player.bufferRange.addListener(_bufferListener);
    player.mediaInfo.addListener(_mediaInfoListener);
    player.playbackState.addListener(_playbackStateListener);
  }

  void _playbackStateListener() {
    if (!playingController.isClosed) {
      playingController.add(isPlaying);
    }

    if (!completedController.isClosed) {
      completedController.add(isCompleted);
    }
  }

  void _mediaInfoListener() {
    final dur = duration();
    if (!durationController.isClosed && dur != null) {
      durationController.add(dur);
    }
  }

  void _volumeListener() {
    if (!volumeController.isClosed) {
      volumeController.add(player.volume.value * 100);
    }
  }

  void _sizeListener() {
    if (!widthController.isClosed) {
      widthController.add(player.videoSize.value.width.toInt());
    }

    if (!heightController.isClosed) {
      heightController.add(player.videoSize.value.height.toInt());
    }
  }

  void _bufferListener() {
    if (!bufferingController.isClosed) {
      bufferingController.add(isBuffering);
    }

  }

  void _positionListener() {
    final pos = position();
    state = state.copyWith(
        playing: isPlaying,
        completed: isCompleted,
        position: pos,
        duration: duration(),
        buffering: isBuffering,
        width: player.videoSize.value.width.toInt(),
        height: player.videoSize.value.height.toInt(),
        volume: player.volume.value,
    );

    if (!positionController.isClosed && !isBuffering) {
      positionController.add(pos);
    }
  }

  bool get isPlaying => player.playbackState.value == PlaybackState.playing;
  bool get isCompleted => player.playbackState.value == PlaybackState.closed;
  bool get isBuffering => player.loading.value;

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
    player.setVolume(volume / 100);
  }

  @override
  Widget videoWidget() {
    return AvMediaView(
      initPlayer: player,
    );
  }
}
