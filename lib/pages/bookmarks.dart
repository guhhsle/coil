import 'package:flutter/material.dart';
import '../data.dart';
import '../playlist/cache.dart';
import '../playlist/playlist.dart';
import '../template/data.dart';
import '../widgets/playlist_tile.dart';

Future<void> fetchBookmarks() async {
  List<Playlist> tempBookmarks = [];
  List<Future> futures = [];
  Playlist.load('Bookmarks', [2]).catchError(
    (e) => Playlist.fromString('Bookmarks')..backup(),
  );
  for (String bookmark in pf['bookmarks']) {
    futures.add(Playlist.load(bookmark, [2, 0, 1]).then(
      (val) => tempBookmarks.add(val),
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
      child: ValueListenableBuilder<List<Playlist>>(
        valueListenable: bookmarks,
        builder: (context, data, child) {
          return ListView(
            physics: scrollPhysics,
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  FutureBuilder(
                    future: Playlist.load('Bookmarks', [2]),
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
                    future: Playlist.load('100', [2]),
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
          );
        },
      ),
    );
  }
}
