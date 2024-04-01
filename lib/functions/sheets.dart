// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:coil/audio/queue.dart';
import 'package:coil/media/audio.dart';
import 'package:coil/media/cache.dart';
import 'package:coil/media/http.dart';
import 'package:coil/media/playlist.dart';
import 'package:coil/playlist/http.dart';
import 'package:flutter/material.dart';

import '../audio/handler.dart';
import '../data.dart';
import '../functions/single_child.dart';
import '../layer.dart';
import '../media/media.dart';
import '../pages/page_artist.dart';
import '../playlist/playlist.dart';
import '../widgets/user_playlists.dart';
import 'generate.dart';
import 'other.dart';

//																	USER PLAYLIST TO MAP

Future<Layer> userPlaylistsToMap(dynamic item) async {
  item as Media;
  if (userPlaylists.value.isEmpty) {
    await fetchUserPlaylists(true);
  }

  Playlist bookmarks = await Playlist.load('Bookmarks', [2]);

  bool bookmarked = bookmarks.list.indexWhere((e) => e.id == item.id) != -1;
  Map<dynamic, bool?> playlists = {};

  for (var map in userPlaylists.value) {
    bool? has;
    try {
      var pl = await Playlist.load(map['id'], [2]);
      has = pl.list.indexWhere((e) => e.id == item.id) != -1;
    } catch (e) {
      //NOT CACHED
    }
    playlists.addAll({map: has});
  }

  return Layer(
    leading: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () async {
            String name = await getInput('', hintText: 'Name');
            Playlist.fromString(name).create();
          }),
    ),
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
    list: playlists.entries
        .map(
          (entry) => Setting(
            entry.key['name'],
            Icons.clear_all_rounded,
            entry.value == null ? '?' : '${entry.value}',
            (c) => item.addToPlaylist(entry.key['id']),
          ),
        )
        .toList(),
  );
}

//																	MEDIA MAP

Future<Layer> mediaToLayer(dynamic media) async {
  media as Media;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  unawaited(media.forceLoad().then((v) => loaded.value = true));
  unawaited(media.getLyrics());
  Layer layer = Layer(
    action: Setting(media.title!, Icons.radio_outlined, '', (c) async {
      await generate([media]);
      Handler().load(Handler().queuePlaying..insert(0, media));
      await Handler().skipTo(0);
      Navigator.of(c).pop();
    }),
    leading: (context) => SizedBox(
      height: 40,
      child: media.image(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        force: true,
      ),
    ),
    list: [
      Setting(
        '',
        Icons.person_outline_rounded,
        media.artist ?? 'Artist',
        (c) => goToPage(
          PageArtist(
            url: media.uploaderUrl ?? '',
            artist: media.artist ?? 'ERROR',
          ),
        ),
      ),
      Setting('', Icons.link_rounded, 'Audio/Video', (c) {
        if (loaded.value) {
          showSheet(func: media.links, hidePrev: c, scroll: true);
        } else {
          loaded.addListener(() {
            if (loaded.value) {
              showSheet(func: media.links, hidePrev: c, scroll: true);
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
          title: media.title!,
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
          media.insertToQueue(Handler().current.value + 1);
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
  if (media.playlist == 'queue') {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Dequeue',
        (c) async {
          Handler().removeItemAt(Handler().queuePlaying.indexOf(media));
        },
      ),
    );
  } else if (media.playlist != null) {
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
