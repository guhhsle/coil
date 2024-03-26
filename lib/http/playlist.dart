// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart';

import '../data.dart';
import '../functions/other.dart';
import '../other/countries.dart';

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
