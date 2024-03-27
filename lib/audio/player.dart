import 'dart:async';

import 'package:coil/functions/other.dart';

import 'queue.dart';
import 'remember.dart';
import '../media/cache.dart';

import '../data.dart';
import '../media/media.dart';
import 'handler.dart';

extension HandlerPlayer on Handler {
  void setVolume() {
    player.setVolume(pf['volume'] / 100);
  }

  Future swap() async {
    if (await player.isPlaying) {
      player.pause();
    } else {
      player.play();
    }
  }

  Future<void> play(Media media) async {
    try {
      unawaited(media.addTo100());
      await player.pause();
      await player.stop();
      await player.open(media.extras['url']);
      player.setMetadata(media);
      int pos = rememberedPosition(media.id);
      if (pos > 10) await player.seek(pos);
      unawaited(player.play());
      unawaited(preload());
    } catch (e) {
      showSnack('$e', false);
    }
  }
}
