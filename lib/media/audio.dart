import 'dart:async';
import 'package:coil/audio/remember.dart';
import '../template/data.dart';
import '../template/functions.dart';
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
      if (await forceLoad() == null) {
        showSnack("Can't load this media on this instance", false);
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
    if (pos / 60 > pf['rememberThreshold']) {
      showSnack('Remembered on ${pos}s', true);
    }
  }

  void addToQueue() => MediaHandler().addToQueue(this);
  void insertToQueue(int index, {bool e = false}) {
    MediaHandler().insertToQueue(this, index, e: e);
  }
}
