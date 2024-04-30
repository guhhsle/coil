// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/single_child.dart';
import 'audio.dart';
import 'http.dart';
import 'lyrics.dart';
import 'playlist.dart';
import 'sheets.dart';
import '../audio/handler.dart';
import '../audio/queue.dart';
import '../functions/generate.dart';
import '../media/media.dart';
import '../pages/artist.dart';

extension MediaSheet on Media {
  Future<Layer> layer(dynamic non) async {
    ValueNotifier<bool> loaded = ValueNotifier(false);
    unawaited(forceLoad().then((v) => loaded.value = true));
    unawaited(getLyrics());
    Layer layer = Layer(
      action: Setting(
        title,
        Icons.radio_outlined,
        '',
        (c) async => compute(generate, [
          [this],
          pf['instance'],
          pf['indie'],
        ]).then((value) {
          MediaHandler().load(value);
          insertToQueue(0);
          MediaHandler().skipTo(0);
          Navigator.of(c).pop();
        }),
      ),
      leading: (context) => [
        SizedBox(
          height: 40,
          child: image(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            force: true,
          ),
        )
      ],
      list: [
        Setting(
          '',
          Icons.person_outline_rounded,
          artist ?? 'Artist',
          (c) => goToPage(
            PageArtist(
              url: uploaderUrl ?? '',
              artist: artist ?? 'ERROR',
            ),
          ),
        ),
        Setting('', Icons.link_rounded, 'Audio/Video', (c) {
          if (loaded.value) {
            showSheet(func: links, hidePrev: c, scroll: true);
          } else {
            loaded.addListener(() {
              if (loaded.value) {
                showSheet(func: links, hidePrev: c, scroll: true);
              }
            });
          }
        }),
        Setting(
          '',
          Icons.playlist_add_rounded,
          'Add to playlist',
          (c) async {
            showSheet(
              func: saved,
              param: null,
              scroll: true,
              hidePrev: c,
            );
          },
        ),
        Setting(
          '',
          Icons.format_align_center,
          'Lyrics',
          (c) => singleChildSheet(
            title: title,
            context: c,
            icon: Icons.format_align_center_rounded,
            child: ValueListenableBuilder<String>(
              valueListenable: currentLyrics,
              builder: (context, snap, child) => Text(snap),
            ),
          ),
        ),
        Setting(
          '',
          Icons.skip_next_rounded,
          'Play next',
          (c) {
            insertToQueue(MediaHandler().index + 1);
            Navigator.of(c).pop();
          },
        ),
        Setting(
          '',
          Icons.wrap_text_rounded,
          'Enqueue',
          (c) {
            addToQueue();
            Navigator.of(c).pop();
          },
        ),
      ],
    );
    if (playlist == 'queue') {
      layer.list.add(
        Setting(
          '',
          Icons.remove_rounded,
          'Dequeue',
          (c) => MediaHandler().removeItemAt(
            MediaHandler().queuePlaying.indexOf(this),
          ),
        ),
      );
    } else if (playlist != null) {
      layer.list.add(
        Setting(
          '',
          Icons.remove_rounded,
          'Remove',
          (c) async {
            Navigator.of(c).pop();
            removeFromPlaylist();
          },
        ),
      );
    }

    return layer;
  }
}
