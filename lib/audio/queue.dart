import 'dart:async';
import 'package:flutter/material.dart';

import '../media/audio.dart';
import '../media/http.dart';
import '../data.dart';
import '../media/media.dart';
import 'handler.dart';

extension HandlerQueue on Handler {
  void load(List<Media> list) {
    if (list == queuePlaying) return;
    queuePlaying.clear();
    for (Media media in list) {
      queuePlaying.add(media..extras['playlist'] = 'queue');
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
    await queuePlaying[i].forceLoad();
    unawaited(queuePlaying[i].play());
    controller.value = PageController(initialPage: i);
    refreshQueue.value = !refreshQueue.value;
  }

  void insertToQueue(
    Media media,
    int index, {
    bool e = false,
  }) {
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

  Future<void> preload({int range = 5}) async {
    var futures = <Future>[];
    if (range == 10) {
      for (int i = 0; i < 10; i++) {
        if (i >= 0 && i < queueLoading.length) {
          futures.add(queueLoading[i].forceLoad());
        }
      }
    } else {
      for (int i = current.value - 2; i < current.value + range; i++) {
        if (i >= 0 && i < queuePlaying.length) {
          futures.add(queuePlaying[i].forceLoad());
        }
      }
    }
    await Future.wait(futures);
  }

  Future<void> removeItemAt(int index) async {
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
