import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data.dart';
import '../functions/other.dart';
import '../layer.dart';
import '../pages/user_playlists.dart';
import '../playlist/playlist.dart';
import 'media.dart';
import 'cache.dart';
import 'http.dart';
import 'playlist.dart';
import '../playlist/http.dart';

extension MediaSheets on Media {
  Future<Layer> links(dynamic non) async {
    await forceLoad();
    return Layer(
      action: Setting('Links', Icons.link_rounded, '', (c) {}),
      list: [
        Setting(
          '',
          Icons.file_download_outlined,
          'Audio',
          (c) async {
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
                  for (int i = audioUrls.length - 1; i >= 0; i--)
                    Setting(
                      '${audioUrls.keys.elementAt(i) == audioUrl ? '>   ' : ''}${audioUrls.values.elementAt(i)}',
                      Icons.graphic_eq_rounded,
                      '',
                      (c) async => await launchUrl(
                        Uri.parse(audioUrls.keys.elementAt(i)),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        Setting(
          '',
          Icons.video_label_rounded,
          'Piped',
          (c) => launchUrl(
            Uri.parse('https://piped.video/watch?v=$id'),
            mode: LaunchMode.externalApplication,
          ),
        ),
        for (Map video in videoUrls)
          Setting(
            video['quality'],
            Icons.theaters_rounded,
            video['format'],
            (c) => launchUrl(
              Uri.parse(video['url']),
              mode: LaunchMode.externalApplication,
            ),
          ),
      ],
    );
  }

  Future<Layer> saved(dynamic non) async {
    if (userPlaylists.value.isEmpty) {
      await fetchUserPlaylists(true);
    }

    Playlist bookmarks = await Playlist.load('Bookmarks', [2]);

    bool bookmarked = bookmarks.list.indexWhere((e) => e.id == id) != -1;
    Map<dynamic, bool?> playlists = {};

    for (var map in userPlaylists.value) {
      bool? has;
      try {
        var pl = await Playlist.load(map['id'], [2]);
        has = pl.list.indexWhere((e) => e.id == id) != -1;
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
          onPressed: () async => Playlist.fromString(
            await getInput('', hintText: 'Name'),
          ).create(),
        ),
      ),
      action: bookmarked
          ? Setting(
              'Bookmarked',
              Icons.bookmark_rounded,
              '',
              (c) async {
                await forceRemoveBackup('Bookmarks');
                refreshLayer();
              },
            )
          : Setting(
              'Bookmark',
              Icons.bookmark_outline_rounded,
              '',
              (c) async {
                await forceAddBackup('Bookmarks');
                refreshLayer();
              },
            ),
      list: playlists.entries
          .map(
            (entry) => Setting(
              entry.key['name'],
              Icons.clear_all_rounded,
              entry.value == null ? '?' : '${entry.value}',
              (c) => addToPlaylist(entry.key['id']),
            ),
          )
          .toList(),
    );
  }
}
