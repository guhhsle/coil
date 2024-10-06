import 'package:coil/media/cache.dart';
import 'package:coil/media/playlist.dart';
import 'package:coil/playlist/http.dart';
import 'package:coil/template/functions.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../media/media.dart';
import '../pages/user_playlists.dart';
import '../playlist/playlist.dart';
import '../template/layer.dart';
import '../template/prefs.dart';
import '../template/tile.dart';

class ListedLayer extends Layer {
  Media media;
  ListedLayer(this.media);
  Map<dynamic, String> playlists = {};

  Future<void> addToMap(dynamic map) async {
    var pl = await Playlist.load(map['id'], [2]);
    if (pl.list.isEmpty) {
      // NOT CACHED
      playlists.addAll({map: '?'});
    } else {
      bool has = pl.list.indexWhere((e) => e.id == media.id) != -1;
      playlists.addAll({map: has ? 'true' : 'false'});
    }
  }

  @override
  void construct() async {
    scroll = true;
    if (userPlaylists.value.isEmpty) {
      await fetchUserPlaylists(true);
    }

    Playlist bookmarks = await Playlist.load('Bookmarks', [2]);
    bool bookmarked = bookmarks.list.indexWhere((e) => e.id == media.id) != -1;

    playlists = {};
    await Future.wait(userPlaylists.value.map((map) => addToMap(map)));

    if (bookmarked) {
      action = Tile('Bookmarked', Icons.bookmark_rounded, '', () async {
        await media.forceRemoveBackup('Bookmarks');
        Preferences.notify();
      });
    } else {
      action = Tile('Bookmark', Icons.bookmark_outline_rounded, '', () async {
        await media.forceAddBackup('Bookmarks');
        Preferences.notify();
      });
    }
    leading = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () async => Playlist.fromString(
            await getInput('', 'Playlist name'),
          ).create(),
        ),
      )
    ];

    list = playlists.entries.map(
      (entry) => Tile(
        entry.key['name'],
        Icons.clear_all_rounded,
        entry.value,
        () => media.addToPlaylist(entry.key['id']),
      ),
    );
    notifyListeners();
  }
}
