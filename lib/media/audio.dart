import 'dart:async';
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
      for (int i = 0; i < 5 && await forceLoad() == null; i++) {}
      showSnack('Still trying to fetch...', false, debug: true);
      for (int i = 1; i < 5 && await forceLoad() == null; i++) {
        await Future.delayed(Duration(seconds: i));
      }
      if (await forceLoad(showError: true) == null) return;
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
