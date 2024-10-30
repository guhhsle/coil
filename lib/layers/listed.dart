import 'package:flutter/material.dart';
import '../pages/user_playlists.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../media/playlist.dart';
import '../template/layer.dart';
import '../template/prefs.dart';
import '../playlist/cache.dart';
import '../playlist/http.dart';
import '../template/tile.dart';
import '../media/media.dart';
import '../data.dart';

class ListedLayer extends Layer {
  Media media;
  ListedLayer(this.media);
  Map<Playlist, String> playlists = {};

  Future<void> checkListed(Playlist playlist) async {
    await playlist.load([2]);
    if (playlist.isEmpty) {
      // NOT CACHED
      playlists.addAll({playlist: '?'});
    } else {
      bool has = playlist.indexOf(media) != -1;
      playlists.addAll({playlist: has ? 'true' : 'false'});
    }
  }

  @override
  void construct() async {
    if (userPlaylists.value.isEmpty) {
      await fetchUserPlaylists(true);
    }

    final bookmarks = Playlist('Bookmarks');
    await bookmarks.load([2]);
    bool bookmarked = bookmarks.indexOf(media) != -1;

    playlists = {};
    await Future.wait(userPlaylists.value.map((map) {
      final playlist = Playlist(map['id']);
      playlist.name = map['name'];
      return checkListed(playlist);
    }));

    if (bookmarked) {
      action = Tile('Bookmarked', Icons.bookmark_rounded, '', () async {
        await Playlist('Bookmarks').forceRemoveMediaFromCache(media);
        Preferences.notify();
      });
    } else {
      action = Tile('Bookmark', Icons.bookmark_outline_rounded, '', () async {
        await Playlist('Bookmarks').forceAddMediaToCache(media);
        Preferences.notify();
      });
    }
    leading = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () async => Playlist(
            await getInput('', 'Playlist name'),
          ).create(),
        ),
      )
    ];

    list = playlists.entries.map(
      (entry) => Tile(
        entry.key.name,
        Icons.clear_all_rounded,
        entry.value,
        () => media.addToPlaylist(entry.key),
      ),
    );
    notifyListeners();
  }
}
