import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'queue.dart';
import 'streams.dart';
import '../threads/main_thread.dart';
import '../media/media.dart';

class MediaHandler extends BaseAudioHandler {
  static final MediaHandler instance = MediaHandler.internal();

  final ValueNotifier<int> position = ValueNotifier(0);
  final ValueNotifier<bool> playing = ValueNotifier(false);
  final ValueNotifier<int> duration = ValueNotifier(1000);
  final ValueNotifier<String> processing = ValueNotifier('idle');

  PageController bottomText = PageController();
  bool loop = false;
  List<Media> queuePlaying = [];
  int index = 0;
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
  Future<void> skipToNext() => skipTo(index + 1);

  @override
  Future<void> skipToPrevious() async {
    if (position.value < 5) {
      skipTo(index - 1);
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
    if (index >= queuePlaying.length) return false;
    return media.id == queuePlaying[index].id;
  }

  void refresh() {
    refreshQueue.value = !refreshQueue.value;
  }

  bool get isEmpty {
    return queuePlaying.isEmpty;
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

  Media get current {
    return queuePlaying[index];
  }
}
