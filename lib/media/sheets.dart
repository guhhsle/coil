import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data.dart';
import '../pages/user_playlists.dart';
import '../playlist/playlist.dart';
import '../template/functions.dart';
import '../template/layer.dart';
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
                  for (MediaLink link in audioUrls)
                    Setting(
                      '${link.url == audioUrl ? '>   ' : ''}${link.bitrate}',
                      Icons.graphic_eq_rounded,
                      link.format ?? '',
                      (c) async => await launchUrl(
                        Uri.parse(link.url),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                ].reversed.toList(),
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
        for (MediaLink link in videoUrls)
          Setting(
            link.quality!,
            Icons.theaters_rounded,
            link.format!,
            (c) => launchUrl(
              Uri.parse(link.url),
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
    Map<dynamic, String> playlists = {};

    for (var map in userPlaylists.value) {
      var pl = await Playlist.load(map['id'], [2]);
      if (pl.list.isEmpty) {
        // NOT CACHED
        playlists.addAll({map: '?'});
      } else {
        bool has = pl.list.indexWhere((e) => e.id == id) != -1;
        playlists.addAll({map: has ? 'true' : 'false'});
      }
    }

    return Layer(
      leading: (context) => [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async => Playlist.fromString(
              await getInput('', hintText: 'Name'),
            ).create(),
          ),
        )
      ],
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
              entry.value,
              (c) => addToPlaylist(entry.key['id']),
            ),
          )
          .toList(),
    );
  }
}
