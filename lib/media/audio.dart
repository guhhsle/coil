import 'dart:async';
import 'bruteforce.dart';
import 'media.dart';
import 'cache.dart';
import 'http.dart';
import '../threads/main_thread.dart';
import '../template/functions.dart';
import '../audio/remember.dart';
import '../audio/handler.dart';
import '../audio/queue.dart';
import '../data.dart';

extension MediaAudio on Media {
  Future<void> play() async {
    if (!offline) {
      addTo100();
      for (int i = 0; i < 3 && await load() == null; i++) {}
      if (await load(showError: true) == null) {
        final layer = BruteForceLayer(this)..bruteForceAll();
        layer.show();
        return;
      }
    }
    int pos = MediaHandler().rememberedPosition(id);
    MainThread.callFn({
      'play': {
        'url': audioUrl,
        'offline': offline,
      }
    });
    if (pos / 60 > Pref.rememberThreshold.value) {
      showSnack('Remembered on ${pos}s', true);
    }
  }

  void addToQueue() => MediaHandler().addToQueue(this);
  void insertToQueue(int index, {bool e = false}) {
    MediaHandler().insertToQueue(this, index, e: e);
  }
}
