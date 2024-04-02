import 'dart:async';
import 'package:flutter/material.dart';

import 'handler.dart';
import '../media/audio.dart';
import '../media/http.dart';
import '../data.dart';
import '../media/media.dart';

extension HandlerQueue on Handler {
  void load(List<Media> list) {
    if (list == queuePlaying) return;
    queuePlaying.clear();
    for (Media media in list) {
      queuePlaying.add(media..playlist = 'queue');
    }
  }

  void addToQueue(Media media) {
    queuePlaying.add(media);
    unawaited(Handler().preload());
    if (queuePlaying.length == 1) Handler().skipTo(0);
    controller.value = PageController(initialPage: current.value);
    refreshQueue.value = !refreshQueue.value;
  }

  Future<void> skipTo(int i) async {
    if (i < 0 || i >= queuePlaying.length) return;
    current.value = i;
    refreshQueue.value = !refreshQueue.value;
    unawaited(queuePlaying[i].play());
    controller.value = PageController(initialPage: i);
    refreshQueue.value = !refreshQueue.value;
  }

  void insertToQueue(Media media, int index, {bool e = false}) {
    if (queuePlaying.isEmpty) {
      addToQueue(media);
      return;
    }
    queuePlaying.insert(index, media);
    unawaited(Handler().preload());
    if (e) {
      current.value = current.value - 1;
    } else if (index <= current.value) {
      current.value = current.value + 1;
    }
    controller.value = PageController(initialPage: current.value);
    refreshQueue.value = !refreshQueue.value;
  }

  Future preload({int range = 5, List<Media>? queue}) async {
    var futures = <Future>[];
    queue ??= queuePlaying;
    for (int i = current.value - 2; i < current.value + range; i++) {
      if (i >= 0 && i < queue.length) {
        futures.add(queue[i].forceLoad());
      }
    }
    await Future.wait(futures);
  }

  void removeItemAt(int index) {
    queuePlaying.removeAt(index);
    unawaited(preload());
    if (index < current.value) current.value = current.value - 1;
    controller.value = PageController(initialPage: current.value);
    refreshQueue.value = !refreshQueue.value;
  }

  void shuffle() {
    Media media = queuePlaying[current.value];
    queuePlaying.shuffle();
    current.value = queuePlaying.indexOf(media);
    controller.value = PageController(initialPage: current.value);
    refreshQueue.value = !refreshQueue.value;
  }
}
