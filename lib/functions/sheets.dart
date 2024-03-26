// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:coil/media/audio.dart';
import 'package:coil/media/cache.dart';
import 'package:coil/media/http.dart';
import 'package:coil/media/playlist.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../functions/single_child.dart';
import '../http/generate.dart';
import '../http/playlist.dart';
import '../layer.dart';
import '../media/media.dart';
import '../pages/page_artist.dart';
import '../playlist/playlist.dart';
import '../widgets/song_tile.dart';

//																	USER PLAYLIST TO MAP

Future<Layer> userPlaylistsToMap(dynamic item) async {
  item as Media;
  if (userPlaylists.value.isEmpty) {
    await fetchUserPlaylists(true);
  }

  Playlist bookmarks = await Playlist.fromStorage('Bookmarks');

  bool bookmarked = bookmarks.list.indexWhere((e) => e.id == item.id) != -1;
  Map<dynamic, bool?> playlists = {};

  for (var map in userPlaylists.value) {
    bool? has;
    try {
      var pl = await Playlist.fromStorage(map['id']);
      has = pl.list.indexWhere((e) => e.id == item.id) != -1;
    } catch (e) {
      //NOT CACHED
    }
    playlists.addAll({map: has});
  }

  return Layer(
    action: bookmarked
        ? Setting(
            'Bookmarked',
            Icons.bookmark_rounded,
            '',
            (c) async {
              await item.forceRemoveBackup('Bookmarks');
              refreshLayer();
            },
          )
        : Setting(
            'Bookmark',
            Icons.bookmark_outline_rounded,
            '',
            (c) async {
              await item.forceAddBackup('Bookmarks');
              refreshLayer();
            },
          ),
    list: [
      for (MapEntry<dynamic, bool?> entry in playlists.entries)
        Setting(
          entry.key['name'],
          Icons.clear_all_rounded,
          entry.value == null ? '?' : '${entry.value}',
          (c) => item.addToPlaylist(entry.key['id']),
        ),
      Setting(
        '',
        Icons.add_rounded,
        '',
        (c) async => await createPlaylist().then((v) {
          refreshLayer();
        }),
      ),
    ],
  );
}

//																	MEDIA MAP

Future<Layer> mediaToLayer(dynamic media) async {
  media as Media;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  unawaited(media.forceLoad().then((v) => loaded.value = true));
  unawaited(media.lyrics());
  Layer layer = Layer(
    action: Setting(media.title, Icons.radio_outlined, '', (c) async {
      await generate([media]);
      load(queuePlaying..insert(0, media));
      await skipTo(0);
      Navigator.of(c).pop();
    }),
    leading: (context) => [
      SizedBox(
        height: 40,
        child: songImage(
          media,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          force: true,
        ),
      )
    ],
    list: [
      Setting(
        '',
        Icons.person_outline_rounded,
        media.artist ?? 'Artist',
        (c) => Navigator.of(c).push(
          MaterialPageRoute(
            builder: (c) => PageArtist(
              url: media.extras!['uploaderUrl'],
              artist: media.artist!,
            ),
          ),
        ),
      ),
      Setting('', Icons.link_rounded, 'Audio/Video', (c) {
        if (loaded.value) {
          media.showLinks(c);
        } else {
          loaded.addListener(() {
            if (loaded.value) {
              media.showLinks(c);
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
            func: userPlaylistsToMap,
            param: media,
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
          title: media.title,
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
          media.insertToQueue(current.value + 1);
          Navigator.of(c).pop();
        },
      ),
      Setting(
        '',
        Icons.wrap_text_rounded,
        'Enqueue',
        (c) {
          media.addToQueue();
          Navigator.of(c).pop();
        },
      ),
    ],
  );
  if (media.extras!['playlist'] == 'queue') {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Dequeue',
        (c) async {
          removeItemAt(queuePlaying.indexOf(media));
        },
      ),
    );
  } else if (media.extras!['playlist'] != null) {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Remove',
        (c) async {
          Navigator.of(c).pop();
          media.removeFromPlaylist();
        },
      ),
    );
  }

  return layer;
}
