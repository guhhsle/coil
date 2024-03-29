import 'dart:convert';

import 'package:coil/media/cache.dart';
import 'package:http/http.dart';

import '../data.dart';
import '../functions/other.dart';
import '../layer.dart';
import '../playlist/playlist.dart';
import 'media.dart';

extension MediaPlaylist on Media {
  Future<void> addToPlaylist(
    String playlistId,
  ) async {
    if (pf['token'] == '') return;
    try {
      Playlist playlist = await Playlist.load(playlistId, [2]);
      if (playlist.list.indexWhere((e) => e.id == id) != -1) {
        showSnack('Already saved, tap to add again', false, onTap: () async {
          await forceAddToPlaylist(playlistId: playlistId);
        });
        return;
      } else {}
    } catch (e) {
      //Playlist not offline
    }
    await forceAddToPlaylist(playlistId: playlistId);
    refreshLayer();
  }

  Future<void> removeFromPlaylist() async {
    if (pf['token'] == '') return;
    if (playlist == null) return;
    if (playlist == 'Bookmarks') {
      await forceRemoveBackup('Bookmarks');
      refreshPlaylist.value = !refreshPlaylist.value;
      return;
    }
    Response response = await post(
      Uri.https(pf['authInstance'], 'user/playlists/remove'),
      headers: {'Authorization': pf['token']},
      body: jsonEncode({
        'playlistId': playlist,
        'index': index,
      }),
    );
    String? error = jsonDecode(response.body)['error'];
    if (error != null) {
      showSnack(error, false);
    }
    await Playlist.load(playlist!, [1, 2]);
    refreshPlaylist.value = !refreshPlaylist.value;
  }

  Future<void> forceAddToPlaylist({
    required String playlistId,
  }) async {
    if (pf['token'] == '') return;
    Response response = await post(
      Uri.https(pf['authInstance'], 'user/playlists/add'),
      headers: {'Authorization': pf['token']},
      body: jsonEncode({'playlistId': playlistId, 'videoId': id}),
    );
    String? error = jsonDecode(response.body)['error'];
    showSnack(error ?? '${l['Added']} $title', error == null);
    await Playlist.load(playlistId, [1, 2]);
    refreshPlaylist.value = !refreshPlaylist.value;
  }
}
