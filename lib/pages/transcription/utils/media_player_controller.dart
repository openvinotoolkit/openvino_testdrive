// Copyright (c) 2024 Intel Corporation

// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:universal_video_controls/universal_players/abstract.dart';
import 'package:video_player/video_player.dart';

class MediaPlayerController extends AbstractPlayer {
  Function(Duration)? onPosition;
  VideoPlayerController? controller;

  MediaPlayerController({this.onPosition});

  void setSource(String file) {
    controller?.dispose();
    controller = VideoPlayerController.file(File(file));
    controller!.initialize().then((_) {
      _initialize();
    });
  }
//
  void _initialize() {
    state = state.copyWith(
        playing: true,
        completed: player.isCompleted,
        position: player.position,
        duration: player.duration,
        buffering: player.isBuffering,
        width: player.size.width.toInt(),
        height: player.size.height.toInt(),
        volume: player.volume,
        subtitle: [],
      );

    controller!.addListener(playbackListener);
    controller!.play();
  }

  VideoPlayerValue get player => controller!.value;

  void playbackListener() {
    if (!playingController.isClosed) {
      playingController.add(player.isPlaying);
    }

    if (!completedController.isClosed) {
      completedController.add(player.isCompleted);
    }

    if (!durationController.isClosed) {
      durationController.add(player.duration);
    }

    if (!volumeController.isClosed) {
      volumeController.add(player.volume * 100);
    }

    if (!bufferingController.isClosed) {
      bufferingController.add(player.isBuffering);
    }

    state = state.copyWith(
        playing: player.isPlaying,
        completed: player.isCompleted,
        position: player.position,
        duration: player.duration,
        buffering: player.isBuffering,
        width: player.size.width.toInt(),
        height: player.size.height.toInt(),
        volume: player.volume,
    );

    if (!positionController.isClosed && !player.isBuffering) {
      positionController.add(player.position);
    }

    onPosition?.call(player.position);
  }

  @override
  Future<void> pause() async {
    controller?.pause();
  }

  @override
  Future<void> play() async {
    controller?.play();
  }

  @override
  Future<void> playOrPause() async {
    if (player.isPlaying) {
      controller?.pause();
    } else {
      controller?.play();
    }
  }

  @override
  Future<void> seek(Duration duration) async {
    controller?.seekTo(duration);
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
    controller?.setVolume(volume / 100);
  }

  @override
  Widget videoWidget() {
    if (controller == null) {
      return Container();
    } else {
      return VideoPlayer(controller!);
    }
  }
}
