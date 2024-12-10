import 'package:av_media_player/player.dart';
import 'package:av_media_player/widget.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';

class AVPlayer extends AbstractPlayer {
  final AvMediaPlayer player;

  AVPlayer(this.player);

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
    if (player.playbackState.value == PlaybackState.paused) {
      player.play();
    } else {
      player.pause();
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
