import 'dart:async';
import 'cache.dart';
import 'http.dart';
import '../audio/queue.dart';
import '../threads/main_thread.dart';
import '../audio/handler.dart';
import 'media.dart';

extension MediaAudio on Media {
  Future<void> play() async {
    if (!offline) {
      unawaited(addTo100());
      if (await forceLoad() == null) return;
    }
    MainThread.callFn({
      'play': {
        'url': audioUrl,
        'offline': offline,
      }
    });
  }

  void addToQueue() => MediaHandler().addToQueue(this);
  void insertToQueue(int index, {bool e = false}) {
    MediaHandler().insertToQueue(this, index, e: e);
  }
}
