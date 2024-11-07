import 'package:flutter/material.dart';
import '../widgets/playlist_tile.dart';
import '../playlist/playlist.dart';
import '../playlist/cache.dart';
import '../template/data.dart';
import '../data.dart';

Future<void> fetchBookmarks() async {
  bookmarks.load().catchError((e) => bookmarks..backup());
  final online = Pref.bookmarks.value.map((url) {
    final playlist = Playlist(url);
    playlist.path = [2, 0, 1];
    return playlist..load();
  });
  allBookmarks.value = [bookmarks, top100, ...online];
}

class Bookmarks extends StatelessWidget {
  const Bookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchBookmarks,
      child: ValueListenableBuilder(
        valueListenable: allBookmarks,
        builder: (context, bookmarks, child) => ListView(
          physics: scrollPhysics,
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          children: bookmarks.map((b) => PlaylistTile(b)).toList(),
        ),
      ),
    );
  }
}
