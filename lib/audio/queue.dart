import 'package:flutter/material.dart';
import 'handler.dart';
import '../media/media_queue.dart';
import '../media/audio.dart';
import '../media/media.dart';

extension QueueHandler on MediaHandler {
  void addToQueue(Media media) {
    tracklist.add(media);
    preload();
    if (tracklist.length == 1) skipTo(0);
    bottomText = PageController(initialPage: index);
    notify();
  }

  void skipToMedia(Media media) => skipTo(tracklist.indexOf(media));

  void skipTo(int i) {
    if (i < 0 || i >= tracklist.length) return;
    index = i;
    tracklist[i].play();
    if (processing.value != 'ready') {
      processing.value = 'loading';
    }
    bottomText = PageController(initialPage: i);
    notify();
  }

  void insertToQueue(Media media, int i, {bool e = false}) {
    if (isEmpty) {
      addToQueue(media);
      return;
    }
    tracklist.insert(i, media);
    preload();
    if (e) {
      index--;
    } else if (i <= index) {
      index++;
    }
    bottomText = PageController(initialPage: index);
    notify();
  }

  void removeItemAt(int i) {
    tracklist.removeAt(i);
    preload();
    if (i < index) index--;
    bottomText = PageController(initialPage: index);
    notify();
  }

  void shuffle() {
    Media media = current;
    tracklist.shuffle();
    index = tracklist.indexOf(media);
    bottomText = PageController(initialPage: index);
    notify();
  }

  Future<void> preload() => tracklist.preload(index - 2, index + 5);

  void load(MediaQueue queue) {
    if (queue == tracklist) return;
    tracklist.setList(queue.list.map((media) {
      return Media.copyFrom(media, queue: tracklist);
    }));
  }
}
