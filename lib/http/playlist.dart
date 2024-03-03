// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:coil/playlist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../data.dart';
import '../functions/cache.dart';
import '../functions/other.dart';
import '../other/countries.dart';
import 'other.dart';

Future<void> renamePlaylist({
  required String newName,
  required String playlistId,
}) async {
  if (pf['token'] == '') return;
  await post(
    Uri.https(pf['authInstance'], 'user/playlists/rename'),
    headers: {'Authorization': pf['token']},
    body: jsonEncode({
      'playlistId': playlistId,
      'newName': newName,
    }),
  );
  unawaited(fetchUserPlaylists(true));
}

Future<void> deletePlaylist(String playlistId) async {
  if (pf['token'] == '') return;
  await post(
    Uri.https(pf['authInstance'], 'user/playlists/delete'),
    headers: {'Authorization': pf['token']},
    body: jsonEncode({'playlistId': playlistId}),
  );
  await fetchUserPlaylists(true);
}

Future<Playlist> loadPlaylist(
  String url,
  List<int> path, {
  int timeTried = 0,
}) async {
  url = formatUrl(url);
  Playlist? list;
  for (int i in path) {
    try {
      if (i == 2) {
        list = await Playlist.fromStorage(url);
        return list;
      } else {
        Uri u = Uri.https(pf[i == 0 ? 'instance' : 'authInstance'], 'playlists/$url');
        list = Playlist.fromJson(jsonDecode(utf8.decode((await get(u)).bodyBytes)), url)..backup();
        return list;
      }
    } catch (e) {
      debugPrint('$e');
    }
  }
  if (timeTried < 4 && list == null) {
    return loadPlaylist(
      url,
      path,
      timeTried: ++timeTried,
    );
  } else {
    return list!;
  }
}

Future<void> fetchUserPlaylists(bool force) async {
  try {
    late List list;
    if (force && pf['token'] != '') {
      Response response = await get(
        Uri.https(pf['authInstance'], 'user/playlists'),
        headers: {'Authorization': pf['token']},
      );
      list = jsonDecode(utf8.decode(response.bodyBytes));
      File file = File('${pf['appDirectory']}/playlists.json');
      file.writeAsBytes(response.bodyBytes);
    } else {
      File file = File('${pf['appDirectory']}/playlists.json');
      list = jsonDecode(await file.readAsString());
      if (list.isEmpty) fetchUserPlaylists(true);
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

Future<void> addToPlaylist({
  required String playlistId,
  required MediaItem item,
  required BuildContext c,
}) async {
  if (pf['token'] == '') return;
  try {
    Playlist playlist = await Playlist.fromStorage(playlistId);
    if (playlist.list.indexWhere((e) => e.id == item.id) != -1) {
      showSnack('Already saved, tap to add again', false, onTap: () async {
        await forceAddToPlaylist(playlistId: playlistId, item: item, c: c);
      });
      return;
    } else {}
  } catch (e) {
    //Playlist not offline
  }
  forceAddToPlaylist(playlistId: playlistId, item: item, c: c);
}

Future<void> removeFromPlaylist({
  required MediaItem item,
}) async {
  if (pf['token'] == '') return;
  if (item.extras!['playlist'] == null) return;
  if (item.extras!['playlist'] == 'Bookmarks') {
    await forceRemoveBackup(item, 'Bookmarks');
    refreshPlaylist.value = !refreshPlaylist.value;
    return;
  }
  Response response = await post(
    Uri.https(pf['authInstance'], 'user/playlists/remove'),
    headers: {'Authorization': pf['token']},
    body: jsonEncode({
      'playlistId': item.extras!['playlist'],
      'index': item.extras!['index'],
    }),
  );
  String? error = jsonDecode(response.body)['error'];
  if (error != null) {
    showSnack(error, false);
  }
  await loadPlaylist(item.extras!['playlist'], [1, 2]);
  refreshPlaylist.value = !refreshPlaylist.value;
}

Future<void> createPlaylist() async {
  if (pf['token'] == '') {
    showSnack('Invalid login', false);
    return;
  }
  await post(
    Uri.https(pf['authInstance'], 'user/playlists/create'),
    body: jsonEncode({'name': '${Random().nextInt(99999)}'}),
    headers: {'Authorization': pf['token']},
  );
  showSnack('${l['Added']}', true);
  await fetchUserPlaylists(true);
}

Future<void> preload({int range = 5}) async {
  var futures = <Future>[];
  if (range == 10) {
    for (int i = 0; i < 10; i++) {
      if (i >= 0 && i < queueLoading.length) {
        futures.add(forceLoad(queueLoading[i]));
      }
    }
  } else {
    for (int i = current.value - 2; i < current.value + range; i++) {
      if (i >= 0 && i < queuePlaying.length) {
        futures.add(forceLoad(queuePlaying[i]));
      }
    }
  }
  await Future.wait(futures);
}

Future<void> forceAddToPlaylist({
  required String playlistId,
  required MediaItem item,
  required BuildContext c,
}) async {
  if (pf['token'] == '') return;
  Response response = await post(
    Uri.https(pf['authInstance'], 'user/playlists/add'),
    headers: {'Authorization': pf['token']},
    body: jsonEncode({'playlistId': playlistId, 'videoId': item.id}),
  );
  String? error = jsonDecode(response.body)['error'];
  showSnack(error ?? '${l['Added']} ${item.title}', error == null);
  await loadPlaylist(playlistId, [1, 2]);
  refreshPlaylist.value = !refreshPlaylist.value;
}
