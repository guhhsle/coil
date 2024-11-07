import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import '../widgets/playlist_tile.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
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
        builder: (context, snap, child) => ListView(
          physics: scrollPhysics,
          padding: const EdgeInsets.only(bottom: 32, top: 16),
          children: [
            for (final playlist in snap) PlaylistTile(playlist),
            Padding(
              padding: const EdgeInsets.all(2),
              child: IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: t('Create a playlist'),
                onPressed: () async => Playlist(
                  await getInput('', 'Playlist name'),
                ).create(),
              ),
            )
          ],
        ),
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
      list = list.reversed.toList();
    } else if (Pref.sortBy.value != 'Default') {
      try {
        list.sort(
          (a, b) => {
            'Name': a['name'].compareTo(b['name']),
            'Name <': b['name'].compareTo(a['name']),
            'Length': a['videos'].compareTo(b['videos']),
            'Length <': b['videos'].compareTo(a['videos']),
          }[Pref.sortBy.value]!,
        );
      } catch (e) {
        debugPrint('$e');
      }
    }
    userPlaylists.value = list.map((map) {
      final playlist = Playlist.fromMap(map);
      playlist.path = [2, 1];
      playlist.load();
      return playlist;
    }).toList();
  } catch (e) {
    if (force) fetchUserPlaylists(false);
  }
}
