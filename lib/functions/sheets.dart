// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:coil/http/other.dart';
import 'package:coil/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../functions/cache.dart';
import '../functions/single_child.dart';
import '../http/generate.dart';
import '../http/playlist.dart';
import '../layer.dart';
import '../pages/page_artist.dart';
import '../playlist.dart';
import '../song.dart';

//																	USER PLAYLIST TO MAP

Future<Layer> userPlaylistsToMap(dynamic item) async {
  item as Song;

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
              await forceRemoveBackup(item, 'Bookmarks');
              refreshLayer();
            },
          )
        : Setting(
            'Bookmark',
            Icons.bookmark_outline_rounded,
            '',
            (c) async {
              await forceAddBackup(item, 'Bookmarks');
              refreshLayer();
            },
          ),
    list: [
      for (MapEntry<dynamic, bool?> entry in playlists.entries)
        Setting(
          entry.key['name'],
          Icons.clear_all_rounded,
          entry.value == null ? '?' : '${entry.value}',
          (c) {
            addToPlaylist(
              playlistId: entry.key['id'],
              item: item,
            );
          },
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

void showLinks(Song song, BuildContext context) {
  Layer layer = Layer(
    action: Setting('Links', Icons.link_rounded, '', (c) {}),
    list: [
      Setting(
        '',
        Icons.file_download_outlined,
        'Audio',
        (c) async {
          if (await canLaunchUrl(Uri.parse(song.extras!['url']))) {
            Map<String, int> map = song.extras!['audioUrls'];
            showSheet(
              scroll: true,
              hidePrev: c,
              func: (non) async => Layer(
                action: Setting(
                  'Bitrate',
                  Icons.graphic_eq_rounded,
                  '',
                  (c) {},
                ),
                list: [
                  for (int i = map.length - 1; i >= 0; i--)
                    Setting(
                      '${map.keys.elementAt(i) == song.extras!['url'] ? '>   ' : ''}${map.values.elementAt(i)}',
                      Icons.graphic_eq_rounded,
                      '',
                      (c) async => await launchUrl(
                        Uri.parse(map.keys.elementAt(i)),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ],
              ),
            );
          }
        },
      ),
      Setting(
        '',
        Icons.video_label_rounded,
        'Piped',
        (c) async {
          if (await canLaunchUrl(Uri.parse('${pf['watchOnPiped']}${song.id}'))) {
            await launchUrl(
              Uri.parse('https://piped.video/watch?v=${song.id}'),
              mode: LaunchMode.externalApplication,
            );
          }
        },
      ),
      for (int i = 0; i < (song.extras!['video'] as List<Map>).length; i++)
        Setting(
          song.extras!['video'][i]['quality'],
          Icons.theaters_rounded,
          song.extras!['video'][i]['format'],
          (c) async {
            if (await canLaunchUrl(Uri.parse(song.extras!['video'][i]['url']))) {
              await launchUrl(
                Uri.parse(song.extras!['video'][i]['url']),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ),
    ],
  );
  showSheet(
    func: (non) async => layer,
    scroll: true,
    hidePrev: context,
  );
}

//																	MEDIA MAP

Future<Layer> mediaToLayer(dynamic song) async {
  song as Song;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  unawaited(forceLoad(song).then((v) => loaded.value = true));
  unawaited(lyrics(song));
  Layer layer = Layer(
    action: Setting(song.title, Icons.radio_outlined, '', (c) async {
      await generate([song]);
      load(queuePlaying..insert(0, song));
      await skipTo(0);
      Navigator.of(c).pop();
    }),
    leading: (context) => [
      SizedBox(
        height: 40,
        child: songImage(
          song,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          force: true,
        ),
      )
    ],
    list: [
      Setting(
        '',
        Icons.person_outline_rounded,
        song.artist ?? 'Artist',
        (c) => Navigator.of(c).push(
          MaterialPageRoute(
            builder: (c) => PageArtist(
              url: song.extras!['uploaderUrl'],
              artist: song.artist!,
            ),
          ),
        ),
      ),
      Setting('', Icons.link_rounded, 'Audio/Video', (c) {
        if (loaded.value) {
          showLinks(song, c);
        } else {
          loaded.addListener(() {
            if (loaded.value) {
              showLinks(song, c);
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
            param: song,
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
          title: song.title,
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
        (c) => insertItemToQueue(current.value + 1, song).then(
          (v) => Navigator.of(c).pop(),
        ),
      ),
      Setting(
        '',
        Icons.wrap_text_rounded,
        'Enqueue',
        (c) => addItemToQueue(song).then(
          (v) => Navigator.of(c).pop(),
        ),
      ),
    ],
  );
  if (song.extras!['playlist'] == 'queue') {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Dequeue',
        (c) async {
          removeItemAt(queuePlaying.indexOf(song));
        },
      ),
    );
  } else if (song.extras!['playlist'] != null) {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Remove',
        (c) async {
          Navigator.of(c).pop();
          removeFromPlaylist(
            item: song,
          );
        },
      ),
    );
  }

  return layer;
}
