// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'listed.dart';
import 'links.dart';
import '../template/single_child.dart';
import '../functions/generate.dart';
import '../template/functions.dart';
import '../media/playlist.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../audio/handler.dart';
import '../media/lyrics.dart';
import '../pages/artist.dart';
import '../media/media.dart';
import '../media/audio.dart';
import '../audio/queue.dart';
import '../media/http.dart';
import '../data.dart';

class MediaLayer extends Layer {
  Media media;
  MediaLayer(this.media);
  @override
  void construct() {
    scroll = true;
    ValueNotifier<bool> loaded = ValueNotifier(false);
    media.forceLoad().then((v) => loaded.value = true);
    media.getLyrics();
    action = Tile(media.title, Icons.radio_outlined, '', () async {
      final suggested = await generate([
        [media],
        Pref.instance.value,
        Pref.indie.value,
      ]);
      MediaHandler().load(suggested);

      media.insertToQueue(0);
      MediaHandler().skipTo(0);
      Navigator.of(context).pop();
    });
    leading = [
      SizedBox(
        height: 40,
        child: media.image(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          force: true,
        ),
      )
    ];
    list = [
      Tile('', Icons.person_outline_rounded, media.artist ?? 'Artist', () {
        goToPage(
          PageArtist(
            url: media.uploaderUrl ?? '',
            artist: media.artist ?? 'ERROR',
          ),
        );
      }),
      Tile('', Icons.link_rounded, 'Audio/Video', () {
        if (loaded.value) {
          Navigator.of(context).pop();
          MediaLinks(media).show();
        } else {
          loaded.addListener(() {
            if (loaded.value) {
              Navigator.of(context).pop();
              MediaLinks(media).show();
            }
          });
        }
      }),
      Tile('', Icons.playlist_add_rounded, 'Add to playlist', () {
        Navigator.of(context).pop();
        ListedLayer(media).show();
      }),
      Tile('', Icons.format_align_center, 'Lyrics', () {
        Navigator.of(context).pop();
        singleChildSheet(
          action: Tile(media.title, Icons.format_align_center_rounded),
          child: ValueListenableBuilder<String>(
            valueListenable: currentLyrics,
            builder: (context, snap, child) => Text(snap),
          ),
        );
      }),
      Tile('', Icons.skip_next_rounded, 'Play next', () {
        media.insertToQueue(MediaHandler().index + 1);
        Navigator.of(context).pop();
      }),
      Tile('', Icons.wrap_text_rounded, 'Enqueue', () {
        media.addToQueue();
        Navigator.of(context).pop();
      }),
    ];
    if (media.playlist == 'queue') {
      list = [
        ...list,
        Tile('', Icons.remove_rounded, 'Dequeue', () {
          MediaHandler().removeItemAt(
            MediaHandler().queuePlaying.indexOf(media),
          );
        }),
      ];
    } else if (media.playlist != null) {
      list = [
        ...list,
        Tile('', Icons.remove_rounded, 'Remove', () {
          Navigator.of(context).pop();
          media.removeFromPlaylist();
        }),
      ];
    }
  }
}
