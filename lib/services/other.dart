// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:coil/functions.dart';
import 'package:coil/services/song.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../other/other.dart';
import '../pages/page_artist.dart';
import '../playlist.dart';
import 'audio.dart';
import 'generate.dart';
import 'playlist.dart';

//																	USER PLAYLIST TO MAP

Future<List<Setting>> userPlaylistsToMap(MediaItem item) async {
  Playlist bookmarks = await Playlist.fromStorage('Bookmarks');
  bool bookmarked = bookmarks.list.indexWhere((e) => e.id == item.id) != -1;
  if (userPlaylists.value.isEmpty) await fetchUserPlaylists(true);
  return [
    bookmarked
        ? Setting(
            'Bookmarked',
            Icons.bookmark_rounded,
            '',
            (c) => forceRemoveBackup(item, 'Bookmarks').then(
              (v) => Navigator.of(c).pop(),
            ),
          )
        : Setting(
            'Bookmark',
            Icons.bookmark_outline_rounded,
            '',
            (c) => forceAddBackup(item, 'Bookmarks').then(
              (v) => Navigator.of(c).pop(),
            ),
          ),
    for (int i = 0; i < userPlaylists.value.length; i++)
      Setting(
        userPlaylists.value[i]['name'],
        Icons.clear_all_rounded,
        '',
        (c) {
          Navigator.of(c).pop();
          addToPlaylist(
            playlistId: userPlaylists.value[i]['id'],
            c: c,
            item: item,
          );
        },
      ),
    Setting(
      '',
      Icons.add_rounded,
      '',
      (c) async => await createPlaylist().then(
        (v) async {
          List<Setting> list = await userPlaylistsToMap(item);
          showSheet(list: (context) => list, scroll: true, hidePrev: c);
        },
      ),
    ),
  ];
}

void showLinks(MediaItem item, BuildContext context) {
  List<Setting> list(BuildContext newContext) => [
        Setting('Links', Icons.link_rounded, '', (c) {}),
        Setting('', Icons.file_download_outlined, 'Audio', (c) async {
          if (await canLaunchUrl(Uri.parse(item.extras!['url']))) {
            Map<String, int> map = item.extras!['audioUrls'];
            showSheet(
              scroll: true,
              hidePrev: newContext,
              list: (context) => [
                Setting(
                  'Bitrate',
                  Icons.graphic_eq_rounded,
                  '',
                  (c) {},
                ),
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
            );
          }
        }),
        Setting('', Icons.video_label_rounded, 'Piped', (c) async {
          if (await canLaunchUrl(Uri.parse('${pf['watchOnPiped']}${item.id}'))) {
            await launchUrl(
              Uri.parse('https://piped.video/watch?v=${item.id}'),
              mode: LaunchMode.externalApplication,
            );
          }
        }),
        for (int i = 0; i < (item.extras!['video'] as List<Map>).length; i++)
          Setting(item.extras!['video'][i]['quality'], Icons.theaters_rounded, item.extras!['video'][i]['format'],
              (c) async {
            if (await canLaunchUrl(Uri.parse(item.extras!['video'][i]['url']))) {
              await launchUrl(
                Uri.parse(item.extras!['video'][i]['url']),
                mode: LaunchMode.externalApplication,
              );
            }
          }),
      ];
  showSheet(
    list: (context) => list(context),
    scroll: true,
    hidePrev: context,
  );
}

//																	MEDIA MAP

List<Setting> mediaToMap(MediaItem item) {
  ValueNotifier<bool> loaded = ValueNotifier(false);
  unawaited(forceLoad(item).then((v) => loaded.value = true));
  unawaited(lyrics(item));
  List<Setting> list = [
    Setting(item.title, Icons.radio_outlined, '', (c) async {
      await generate([item]);
      load(queuePlaying..insert(0, item));
      await skipTo(0);
      Navigator.of(c).pop();
    }),
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
        List<Setting> list = await userPlaylistsToMap(item);
        showSheet(list: (context) => list, scroll: true, hidePrev: c);
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
  ];
  if (item.extras!['playlist'] != null) {
    list.add(
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

  return list;
}
