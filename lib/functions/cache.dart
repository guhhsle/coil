import '../data.dart';
import '../playlist/playlist.dart';

Future<void> refreshBookmarks() async {
  Playlist.fromStorage('Bookmarks').catchError(
    (e) => Playlist.fromJson(
      {
        "name": "Bookmarks",
        "thumbnailUrl": "",
        "uploader": "Local",
        "videos": 0,
        "relatedStreams": <Map>[],
      },
      'Bookmarks',
    )..backup(),
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
