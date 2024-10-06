import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import '../widgets/playlist_tile.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../template/prefs.dart';
import '../playlist/http.dart';
import '../template/data.dart';
import '../data.dart';

class UserPlaylists extends StatelessWidget {
  const UserPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => fetchUserPlaylists(true),
      child: ValueListenableBuilder(
        valueListenable: userPlaylists,
        builder: (context, snap, child) {
          return ListView(
            physics: scrollPhysics,
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            children: [
              for (Map map in snap)
                PlaylistTile(
                  info: map,
                  playlist: true,
                  path: const [2, 1],
                ),
              Padding(
                padding: const EdgeInsets.all(2),
                child: IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: t('Create a playlist'),
                  onPressed: () async => Playlist.fromString(
                    await getInput('', 'Playlist name'),
                  ).create(),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

Future<void> fetchUserPlaylists(bool force) async {
  try {
    List list = [];
    File file = File('${Pref.appDirectory.value}/playlists.json');
    if (force && Pref.token.value != '') {
      Response response = await get(
        Uri.https(Pref.authInstance.value, 'user/playlists'),
        headers: {'Authorization': Pref.token.value},
      );
      list = jsonDecode(utf8.decode(response.bodyBytes));
      await file.writeAsBytes(response.bodyBytes);
    } else {
      list = jsonDecode(await file.readAsString());
      if (list.isEmpty && !force) fetchUserPlaylists(true);
    }
    if (Pref.sortBy.value == 'Default <') {
      List r = List.from(list.reversed);
      list = r.toList();
    } else if (Pref.sortBy.value != 'Default') {
      list.sort(
        (a, b) => {
          'Name': a['name'].compareTo(b['name']),
          'Name <': b['name'].compareTo(a['name']),
          'Length': a['videos'].compareTo(b['videos']),
          'Length <': b['videos'].compareTo(a['videos']),
        }[Pref.sortBy.value]!,
      );
    }
    userPlaylists.value = list;
  } catch (e) {
    if (force) fetchUserPlaylists(false);
  }
  Preferences.notify();
}
