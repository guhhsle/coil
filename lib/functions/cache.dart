import '../playlist/cache.dart';
import '../data.dart';
import '../playlist/playlist.dart';

Future<void> refreshBookmarks() async {
  Playlist.load('Bookmarks', [2]).catchError(
    (e) => Playlist.fromString('Bookmarks')..backup(),
  );
}

Future<void> fetchBookmarks() async {
  List<Playlist> tempBookmarks = [];
  List<Future> futures = [];

  refreshBookmarks();

  for (int i = 0; i < pf['bookmarks'].length; i++) {
    futures.add(Playlist.load(pf['bookmarks'][i], [2, 0, 1]).then(
      (val) => tempBookmarks.add(val),
    ));
  }
  await Future.wait(futures);
  bookmarks.value = tempBookmarks;
}
