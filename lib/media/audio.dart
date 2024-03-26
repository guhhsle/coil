import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../data.dart';
import '../functions/audio.dart';
import 'media.dart';
import 'cache.dart';

extension MediaAudio on Media {
  void addToQueue() {
    queuePlaying.add(this);
    unawaited(preload());
    if (queuePlaying.length == 1) skipTo(0);
    controller.value = PageController(initialPage: current.value);
    refreshQueue.value = !refreshQueue.value;
  }

  void insertToQueue(
    int index, {
    bool e = false,
  }) {
    if (queuePlaying.isEmpty) {
      addToQueue();
      return;
    }
    queuePlaying.insert(index, this);
    unawaited(preload());
    if (e) {
      current.value = current.value - 1;
    } else if (index <= current.value) {
      current.value = current.value + 1;
    }
    controller.value = PageController(initialPage: current.value);
    refreshQueue.value = !refreshQueue.value;
  }

  Future<void> play() async {
    if (extras!['offline'] == null) {
      unawaited(addTo100());
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(extras!['url']), tag: this),
      );
    } else {
      await player.setAudioSource(
        AudioSource.file(extras!['url'], tag: this),
      );
    }
    int pos = rememberedPosition(id);
    if (pos > 10) await player.seek(Duration(seconds: pos));
    unawaited(player.play());
    unawaited(preload());
  }
}
