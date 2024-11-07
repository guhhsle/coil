import 'package:flutter/material.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../media/playlist.dart';
import '../template/layer.dart';
import '../playlist/cache.dart';
import '../playlist/http.dart';
import '../template/tile.dart';
import '../media/media.dart';
import '../data.dart';

class ListedLayer extends Layer {
  Media media;
  ListedLayer(this.media);

  @override
  void construct() {
    listenTo(bookmarks);
    userPlaylists.value.forEach(listenTo);

    final playlists = Map.fromEntries(userPlaylists.value.map((playlist) {
      if (playlist.isEmpty) return MapEntry(playlist, '?');
      return MapEntry(playlist, playlist.contains(media) ? 'true' : 'false');
    }));

    if (bookmarks.contains(media)) {
      action = Tile('Bookmarked', Icons.bookmark_rounded, '', () {
        bookmarks.forceRemoveMediaFromCache(media);
      });
    } else {
      action = Tile('Bookmark', Icons.bookmark_outline_rounded, '', () {
        bookmarks.forceAddMediaToCache(media);
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
  }
}
