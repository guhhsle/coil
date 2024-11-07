import 'package:flutter/material.dart';
import '../widgets/playlist_tile.dart';
import '../playlist/playlist.dart';
import '../playlist/cache.dart';
import '../template/data.dart';
import '../data.dart';

Future<void> fetchBookmarks() async {
  List<Playlist> tempBookmarks = [];
  List<Future> futures = [];
  bookmarks.load().catchError((e) => bookmarks..backup());
  for (final url in Pref.bookmarks.value) {
    final playlist = Playlist(url);
    playlist.path = [2, 0, 1];
    futures.add(playlist.load().then((_) {
      tempBookmarks.add(playlist);
    }));
  }
  await Future.wait(futures);
  allBookmarks.value = tempBookmarks;
}

class Bookmarks extends StatelessWidget {
  const Bookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchBookmarks,
      child: ValueListenableBuilder(
        valueListenable: allBookmarks,
        builder: (context, data, child) => ListView(
          physics: scrollPhysics,
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                FutureBuilder(
                  future: bookmarks.load(),
                  builder: (context, snap) {
                    if (snap.hasError) return Container();
                    return PlaylistTile(playlist: bookmarks);
                  },
                ),
                FutureBuilder(
                  future: top100.load(),
                  builder: (context, snap) {
                    if (snap.hasError) return Container();
                    return PlaylistTile(playlist: top100);
                  },
                ),
                for (final playlist in data) PlaylistTile(playlist: playlist),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
