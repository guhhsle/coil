import 'dart:async';

import 'package:coil/functions/other.dart';
import 'package:coil/media/http.dart';

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
      unawaited(player.setMetadata(media));
      await media.forceLoad();
      if (media.audioUrl == null) {
        throw "Can't load this song";
      } else {
        await player.pause();
        await player.stop();
        await player.open(media.audioUrl!);
        int pos = rememberedPosition(media.id);
        if (pos > 10) await player.seek(pos);
        unawaited(player.play());
      }
      unawaited(preload());
    } catch (e) {
      showSnack('$e', false);
    }
  }
}
