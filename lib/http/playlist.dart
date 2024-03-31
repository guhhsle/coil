import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coil/playlist/cache.dart';
import 'package:http/http.dart';

import '../data.dart';
import '../functions/other.dart';
import '../other/countries.dart';
import '../playlist/playlist.dart';

Future<void> fetchUserPlaylists(bool force) async {
  try {
    late List list;
    File file = File('${pf['appDirectory']}/playlists.json');
    if (force && pf['token'] != '') {
      Response response = await get(
        Uri.https(pf['authInstance'], 'user/playlists'),
        headers: {'Authorization': pf['token']},
      );
      list = jsonDecode(utf8.decode(response.bodyBytes));
      await file.writeAsBytes(response.bodyBytes);
    } else {
      list = jsonDecode(await file.readAsString());
      if (list.isEmpty && !force) fetchUserPlaylists(true);
    }
    if (pf['sortBy'] == 'Default <') {
      List r = List.from(list.reversed);
      list = r.toList();
    } else if (pf['sortBy'] != 'Default') {
      list.sort(
        (a, b) => {
          'Name': a['name'].compareTo(b['name']),
          'Name <': b['name'].compareTo(a['name']),
          'Length': a['videos'].compareTo(b['videos']),
          'Length <': b['videos'].compareTo(a['videos']),
        }[pf['sortBy']]!,
      );
    }
    userPlaylists.value = list;
  } catch (e) {
    if (force) fetchUserPlaylists(false);
  }
}

Future<void> trending() async {
  Response response = await get(Uri.https(pf['instance'], 'trending', {
    'region': countries.keys.elementAt(
      countries.values.toList().indexOf(pf['location']),
    ),
  }));
  trendingVideos.value = jsonDecode(utf8.decode(response.bodyBytes));
}

Future<void> createPlaylist() async {
  String name = await getInput('', hintText: 'Name');
  if (pf['token'] == '') {
    Playlist localPlaylist = Playlist.fromString('$name-${DateTime.now()}');
    localPlaylist.name = name;
    await localPlaylist.addToCache();
    await localPlaylist.backup();
  } else {
    try {
      await post(
        Uri.https(pf['authInstance'], 'user/playlists/create'),
        body: jsonEncode({'name': name}),
        headers: {'Authorization': pf['token']},
      );
    } catch (e) {
      showSnack('$e', false);
    }
  }
  await fetchUserPlaylists(true);
}
