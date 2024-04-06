import 'dart:async';

import 'package:coil/media/audio.dart';
import 'package:coil/media/http.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../media/media.dart';
import 'handler.dart';

extension QueueHandler on MediaHandler {
  void addToQueue(Media media) {
    queuePlaying.add(media);
    unawaited(preload());
    if (queuePlaying.length == 1) skipTo(0);
    controller.value = PageController(initialPage: current.value);
    refresh();
  }

  Future<void> skipTo(int i) async {
    if (i < 0 || i >= queuePlaying.length) return;
    current.value = i;
    queuePlaying[i].play();
    controller.value = PageController(initialPage: i);
    refresh();
  }

  void insertToQueue(Media media, int index, {bool e = false}) {
    if (queuePlaying.isEmpty) {
      addToQueue(media);
      return;
    }
    queuePlaying.insert(index, media);
    unawaited(preload());
    if (e) {
      current.value = current.value - 1;
    } else if (index <= current.value) {
      current.value = current.value + 1;
    }
    controller.value = PageController(initialPage: current.value);
    refresh();
  }

  void removeItemAt(int index) {
    queuePlaying.removeAt(index);
    unawaited(preload());
    if (index < current.value) current.value = current.value - 1;
    controller.value = PageController(initialPage: current.value);
    refresh();
  }

  void shuffle() {
    Media media = queuePlaying[current.value];
    queuePlaying.shuffle();
    current.value = queuePlaying.indexOf(media);
    controller.value = PageController(initialPage: current.value);
    refresh();
  }

  Future<void> preload() => queuePlaying.preload(
        current.value - 2,
        current.value + 5,
      );

  void load(List<Media> list) {
    if (list == queuePlaying) return;
    queuePlaying.clear();
    for (Media media in list) {
      queuePlaying.add(media..playlist = 'queue');
    }
  }
}
