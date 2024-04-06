import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'queue.dart';
import 'streams.dart';
import '../threads/main_thread.dart';
import '../media/media.dart';

enum LoopMode { off, one, all }

class MediaHandler extends BaseAudioHandler {
  static final MediaHandler instance = MediaHandler.internal();
  final StreamController<int> position = StreamController.broadcast();
  final StreamController<bool> playing = StreamController.broadcast();
  final StreamController<int> duration = StreamController.broadcast();
  final StreamController<String> processing = StreamController.broadcast();
  int lastDuration = 1000;
  int lastPosition = 0;
  bool lastPlaying = false;
  LoopMode loop = LoopMode.off;
  List<Media> queuePlaying = [];
  final ValueNotifier<int> current = ValueNotifier(0);
  static final ValueNotifier<bool> refreshQueue = ValueNotifier(false);

  factory MediaHandler() {
    return instance;
  }

  MediaHandler.internal() {
    AudioService.init(builder: () => this).then((value) {
      value.initStreams();
    });
  }

  @override
  Future<void> skipToNext() => skipTo(current.value + 1);

  @override
  Future<void> skipToPrevious() async {
    if (lastPosition < 5) {
      skipTo(current.value - 1);
    } else {
      MainThread.callFn({'seek': 0});
    }
  }

  @override
  Future<void> play() => MainThread.callFn({'resume': null});

  @override
  Future<void> pause() => MainThread.callFn({'pause': null});

  @override
  Future<void> stop() async {
    MainThread.callFn({'stop': null});
    refresh();
    queuePlaying.clear();
  }

  @override
  Future<void> seek(Duration position) => MainThread.callFn({
        'seek': position.inSeconds,
      });

  bool selected(Media media) {
    if (current.value >= queuePlaying.length) return false;
    return media.id == queuePlaying[current.value].id;
  }

  void refresh() {
    refreshQueue.value = !refreshQueue.value;
  }

  bool tryLoad(Media media) {
    for (int q = 0; q < queuePlaying.length; q++) {
      if (queuePlaying[q].id == media.id && queuePlaying[q].audioUrl != null) {
        media.audioUrl = queuePlaying[q].audioUrl;
        media.audioUrls = queuePlaying[q].audioUrls;
        media.videoUrls = queuePlaying[q].videoUrls;
        return true;
      }
    }
    return false;
  }

  Media get now {
    return queuePlaying[current.value];
  }
}
