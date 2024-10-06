import 'package:http/http.dart';
import 'dart:convert';
import 'media.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../functions/other.dart';
import '../template/prefs.dart';
import '../template/data.dart';
import '../media/cache.dart';
import '../data.dart';

extension MediaPlaylist on Media {
  Future<void> addToPlaylist(String playlistId) async {
    try {
      Playlist playlist = await Playlist.load(playlistId, [2]);
      if (playlist.list.indexWhere((e) => e.id == id) != -1) {
        showSnack(
          'Already saved, tap to add again',
          false,
          onTap: () async => await forceAddToPlaylist(playlistId),
        );
        return;
      }
    } catch (e) {
      //Playlist not offline
    }
    await forceAddToPlaylist(playlistId);
  }

  Future<void> removeFromPlaylist() async {
    if (playlist == null) return;
    if (playlistIsCacheOnly(playlist!)) {
      await forceRemoveBackup(playlist!, first: false);
    } else {
      Response response = await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/remove'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({'playlistId': playlist, 'index': index}),
      );
      String? error = jsonDecode(response.body)['error'];
      if (error != null) {
        showSnack(error, false);
      }
      await Playlist.load(playlist!, [1, 2]);
      refreshList();
      Preferences.notify();
    }
  }

  Future<void> forceAddToPlaylist(String playlistId) async {
    if (playlistIsCacheOnly(playlistId)) {
      await forceAddBackup(playlistId);
    } else {
      showSnack('Loading', true);
      Response response = await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/add'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({'playlistId': playlistId, 'videoId': id}),
      );
      String? error = jsonDecode(response.body)['error'];
      showSnack(error ?? '${l['Added']} $title', error == null);
      await Playlist.load(playlistId, [1, 2]);
      refreshList();
      Preferences.notify();
    }
  }
}
