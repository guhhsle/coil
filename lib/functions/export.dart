import 'dart:convert';

import '../data.dart';
import '../functions/other.dart';
import '../pages/user_playlists.dart';
import '../playlist/playlist.dart';

//BULK INDICATES ONE BIG FILE
Future<void> exportUser(bool bulk) async {
  playlists = [];
  showSnack('Loading', true);
  await fetchUserPlaylists(true);
  var futures = <Future>[];
  for (int i = 0; i < userPlaylists.value.length; i++) {
    futures.add(exportPlaylist(i, null));
  }
  await Future.wait(futures);
  for (int i = 0; i < playlists.length; i++) {
    try {
      await writeFile(
        bulk ? 'playlists.json' : '${playlists[i]['name']}.json',
        jsonEncode({
          'format': 'Piped',
          'version': 1,
          'playlists': bulk ? playlists : [playlists[i]],
        }),
      );
    } catch (e) {
      showSnack('$e', false);
    }
    if (bulk) i = playlists.length;
  }
}

List<Map> playlists = [];
//TEMPORARY VARIABLE FOR SAVING USER PLAYLISTS

Future<void> exportPlaylist(int i, Playlist? list) async {
  List<String> videos = [];
  list ??= await Playlist.load(userPlaylists.value[i]['id'], [1, 2]);
  for (int j = 0; j < list.list.length; j++) {
    videos.add('https://youtube.com${list.list[j].id}');
  }
  playlists.add({
    'name': formatList(list.name),
    'type': 'playlist',
    'visibility': 'private',
    'videos': videos,
  });
}

Future<void> exportOther(Playlist list) async {
  playlists = [];
  await exportPlaylist(0, list);
  try {
    await writeFile(
      '${playlists[0]['name']}.json',
      jsonEncode({
        'format': 'Piped',
        'version': 1,
        'playlists': playlists,
      }),
    );
  } catch (e) {
    showSnack('$e', false);
  }
}
