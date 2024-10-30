import 'package:coil/playlist/cache.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'media.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../template/prefs.dart';
import '../template/data.dart';
import '../data.dart';

extension MediaPlaylist on Media {
  Future<void> addToPlaylist(Playlist playlist) async {
    try {
      await playlist.load([2]);
      if (playlist.indexOf(this) != -1) {
        showSnack(
          'Already saved, tap to add again',
          false,
          onTap: () async => await forceAddToPlaylist(playlist),
        );
        return;
      }
    } catch (e) {
      //Playlist not offline
    }
    await forceAddToPlaylist(playlist);
  }

  Future<void> removeFromPlaylist() async {
    final playlistID = (queue as Playlist).url;
    if (playlistIsCacheOnly(playlistID)) {
      await Playlist(playlistID).forceRemoveMediaFromCache(
        this,
        first: false,
      );
    } else {
      Response response = await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/remove'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({'playlistId': playlistID, 'index': index}),
      );
      String? error = jsonDecode(response.body)['error'];
      if (error != null) {
        showSnack(error, false);
      }
      await Playlist(playlistID).load([1, 2]);
      Preferences.notify();
    }
  }

  Future<void> forceAddToPlaylist(Playlist playlist) async {
    if (playlistIsCacheOnly(playlist.url)) {
      await playlist.forceAddMediaToCache(this);
    } else {
      showSnack('Loading', true);
      Response response = await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/add'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({'playlistId': playlist.raw['id'], 'videoId': id}),
      );
      String? error = jsonDecode(response.body)['error'];
      showSnack(error ?? '${l['Added']} $title', error == null);

      await playlist.load([1, 2]);
      Preferences.notify();
    }
  }
}
