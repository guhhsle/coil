import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../layer.dart';
import '../playlist/http.dart';
import '../data.dart';
import '../functions/other.dart';
import '../playlist/playlist.dart';
import '../widgets/playlist_tile.dart';

class UserPlaylists extends StatelessWidget {
  const UserPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => fetchUserPlaylists(true),
      child: ValueListenableBuilder<List>(
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
                  tooltip: l['Create a playlist'],
                  onPressed: () async {
                    String name = await getInput('', hintText: 'Name');
                    Playlist.fromString(name).create();
                  },
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
  refreshLayer();
}
