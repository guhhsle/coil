import 'package:flutter/material.dart';
import '../widgets/playlist_tile.dart';
import '../playlist/playlist.dart';
import '../playlist/cache.dart';
import '../template/data.dart';
import '../data.dart';

Future<void> fetchBookmarks() async {
  List<Playlist> tempBookmarks = [];
  List<Future> futures = [];
  Playlist('Bookmarks').load([2]).catchError(
    (e) => Playlist('Bookmarks')..backup(),
  );
  for (String url in Pref.bookmarks.value) {
    final playlist = Playlist(url);
    futures.add(playlist.load([2, 0, 1]).then(
      (val) => tempBookmarks.add(playlist),
    ));
  }
  await Future.wait(futures);
  bookmarks.value = tempBookmarks;
}

class Bookmarks extends StatelessWidget {
  const Bookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchBookmarks,
      child: ValueListenableBuilder(
        valueListenable: bookmarks,
        builder: (context, data, child) => ListView(
          physics: scrollPhysics,
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                FutureBuilder(
                  future: Playlist('Bookmarks').load([2]),
                  builder: (context, snap) {
                    if (snap.hasError) return Container();
                    return const PlaylistTile(
                      info: {'url': 'Bookmarks'},
                      playlist: true,
                      path: [2],
                    );
                  },
                ),
                FutureBuilder(
                  future: Playlist('100').load([2]),
                  builder: (context, snap) {
                    if (snap.hasError) return Container();
                    return const PlaylistTile(
                      info: {'url': '100'},
                      playlist: true,
                      path: [2],
                    );
                  },
                ),
                for (Playlist item in data)
                  PlaylistTile(
                    info: {
                      'url': item.url,
                      'thumbnail': item.thumbnail,
                      'title': item.name,
                    },
                    playlist: true,
                    path: const [2, 0, 1],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
