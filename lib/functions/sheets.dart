// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:coil/http/other.dart';
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

//																	USER PLAYLIST TO MAP

Future<Layer> userPlaylistsToMap(dynamic item) async {
  item as MediaItem;

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

void showLinks(MediaItem item, BuildContext context) {
  Layer layer = Layer(
    action: Setting('Links', Icons.link_rounded, '', (c) {}),
    list: [
      Setting(
        '',
        Icons.file_download_outlined,
        'Audio',
        (c) async {
          if (await canLaunchUrl(Uri.parse(item.extras!['url']))) {
            Map<String, int> map = item.extras!['audioUrls'];
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
                      '${map.keys.elementAt(i) == item.extras!['url'] ? '>   ' : ''}${map.values.elementAt(i)}',
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
          if (await canLaunchUrl(Uri.parse('${pf['watchOnPiped']}${item.id}'))) {
            await launchUrl(
              Uri.parse('https://piped.video/watch?v=${item.id}'),
              mode: LaunchMode.externalApplication,
            );
          }
        },
      ),
      for (int i = 0; i < (item.extras!['video'] as List<Map>).length; i++)
        Setting(
          item.extras!['video'][i]['quality'],
          Icons.theaters_rounded,
          item.extras!['video'][i]['format'],
          (c) async {
            if (await canLaunchUrl(Uri.parse(item.extras!['video'][i]['url']))) {
              await launchUrl(
                Uri.parse(item.extras!['video'][i]['url']),
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

Future<Layer> mediaToLayer(dynamic item) async {
  item as MediaItem;
  ValueNotifier<bool> loaded = ValueNotifier(false);
  unawaited(forceLoad(item).then((v) => loaded.value = true));
  unawaited(lyrics(item));
  Layer layer = Layer(
    action: Setting(item.title, Icons.radio_outlined, '', (c) async {
      await generate([item]);
      load(queuePlaying..insert(0, item));
      await skipTo(0);
      Navigator.of(c).pop();
    }),
    list: [
      Setting(
        '',
        Icons.person_outline_rounded,
        item.artist ?? 'Artist',
        (c) => Navigator.of(c).push(
          MaterialPageRoute(
            builder: (c) => PageArtist(
              url: item.extras!['uploaderUrl'],
              artist: item.artist!,
            ),
          ),
        ),
      ),
      Setting('', Icons.link_rounded, 'Audio/Video', (c) {
        if (loaded.value) {
          showLinks(item, c);
        } else {
          loaded.addListener(() {
            if (loaded.value) {
              showLinks(item, c);
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
            param: item,
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
          title: item.title,
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
        (c) => insertItemToQueue(current.value + 1, item).then(
          (v) => Navigator.of(c).pop(),
        ),
      ),
      Setting(
        '',
        Icons.wrap_text_rounded,
        'Enqueue',
        (c) => addItemToQueue(item).then(
          (v) => Navigator.of(c).pop(),
        ),
      ),
    ],
  );
  if (item.extras!['playlist'] == 'queue') {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Dequeue',
        (c) async {
          removeItemAt(queuePlaying.indexOf(item));
        },
      ),
    );
  } else if (item.extras!['playlist'] != null) {
    layer.list.add(
      Setting(
        '',
        Icons.remove_rounded,
        'Remove',
        (c) async {
          Navigator.of(c).pop();
          removeFromPlaylist(
            item: item,
          );
        },
      ),
    );
  }

  return layer;
}
