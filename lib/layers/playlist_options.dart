// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../playlist/playlist.dart';
import '../functions/export.dart';
import '../pages/bookmarks.dart';
import '../functions/other.dart';
import '../template/layer.dart';
import '../playlist/http.dart';
import '../template/tile.dart';
import '../audio/handler.dart';
import '../audio/queue.dart';
import '../data.dart';

class PlaylistOptions extends Layer {
  Playlist playlist;
  List<int> path;
  PlaylistOptions(this.playlist, this.path);
  @override
  void construct() {
    action = Tile('Refresh', Icons.refresh_rounded, '', () async {
      path.remove(2);
      playlist = await Playlist.load(playlist.url, path);
      refreshList();
      Navigator.of(context).pop();
    });
    list = [
      Tile('Shuffle', Icons.low_priority, '', () {
        MediaHandler().load(playlist.list);
        MediaHandler().shuffle();
        MediaHandler().skipTo(0);
        Navigator.of(context).pop();
      }),
      if (Pref.bookmarks.value.contains(playlist.url))
        Tile('Remove from bookmarks', Icons.bookmark_rounded, '', () {
          Pref.bookmarks.set(Pref.bookmarks.value..remove(playlist.url));
          fetchBookmarks();
        })
      else
        Tile('Bookmark', Icons.bookmark_border_rounded, '', () async {
          await Pref.bookmarks.set(Pref.bookmarks.value..add(playlist.url));
          fetchBookmarks();
        }),
      Tile('Export', Icons.settings_backup_restore_rounded, '', () {
        Navigator.of(context).pop();
        exportOther(playlist);
      }),
      Tile('Creator', Icons.person_rounded, playlist.uploader),
      Tile('Items', Icons.numbers_rounded, '${playlist.items}'),
      Tile('Delete', Icons.delete_forever_rounded, 'Forever', () {
        DeletePlaylist(playlist).show();
      }),
    ];
  }
}

class DeletePlaylist extends Layer {
  Playlist playlist;
  DeletePlaylist(this.playlist);
  @override
  void construct() {
    action = Tile('Delete', Icons.delete_forever_rounded, '', () async {
      await playlist.delete();
      Navigator.of(context).pop();
    });
  }
}
