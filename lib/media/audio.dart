import 'dart:async';

import '../audio/player.dart';
import '../audio/queue.dart';
import '../audio/handler.dart';
import 'media.dart';

extension MediaAudio on Media {
  Future<void> play() => Handler().play(this);
  void addToQueue() => Handler().addToQueue(this);
  void insertToQueue(
    int index, {
    bool e = false,
  }) =>
      Handler().insertToQueue(this, index, e: e);
}
