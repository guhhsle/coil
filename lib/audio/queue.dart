import 'dart:async';
import 'package:coil/media/audio.dart';
import 'package:coil/media/http.dart';
import 'package:flutter/material.dart';
import '../media/media.dart';
import 'handler.dart';

extension QueueHandler on MediaHandler {
  void addToQueue(Media media) {
    queuePlaying.add(media);
    unawaited(preload());
    if (queuePlaying.length == 1) skipTo(0);
    bottomText = PageController(initialPage: index);
    refresh();
  }

  Future<void> skipTo(int i) async {
    if (i < 0 || i >= queuePlaying.length) return;
    index = i;
    queuePlaying[i].play();
    if (processing.value != 'ready') {
      processing.value = 'loading';
    }
    bottomText = PageController(initialPage: i);
    refresh();
  }

  void insertToQueue(Media media, int i, {bool e = false}) {
    if (queuePlaying.isEmpty) {
      addToQueue(media);
      return;
    }
    queuePlaying.insert(i, media);
    unawaited(preload());
    if (e) {
      index--;
    } else if (i <= index) {
      index++;
    }
    bottomText = PageController(initialPage: index);
    refresh();
  }

  void removeItemAt(int i) {
    queuePlaying.removeAt(i);
    unawaited(preload());
    if (i < index) index--;
    bottomText = PageController(initialPage: index);
    refresh();
  }

  void shuffle() {
    Media media = current;
    queuePlaying.shuffle();
    index = queuePlaying.indexOf(media);
    bottomText = PageController(initialPage: index);
    refresh();
  }

  Future<void> preload() => queuePlaying.preload(index - 2, index + 5);

  void load(List<Media> list) {
    if (list == queuePlaying) return;
    queuePlaying.clear();
    for (Media media in list) {
      queuePlaying.add(media..playlist = 'queue');
    }
  }
}
