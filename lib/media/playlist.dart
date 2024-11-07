import 'package:http/http.dart';
import 'dart:convert';
import 'media.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../playlist/cache.dart';
import '../template/data.dart';
import '../data.dart';

extension MediaPlaylist on Media {
  Future<void> addToPlaylist(Playlist playlist) async {
    if (!playlist.contains(this)) {
      return forceAddToPlaylist(playlist);
    }
    showSnack(
      'Already saved, tap to add again',
      false,
      onTap: () => forceAddToPlaylist(playlist),
    );
  }

  Future<void> removeFromPlaylist() async {
    final playlist = queue as Playlist;
    if (playlistIsCacheOnly(playlist.url)) {
      await playlist.forceRemoveMediaFromCache(
        this,
        first: false,
      );
    } else {
      Response response = await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/remove'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({'playlistId': playlist.url, 'index': index}),
      );
      String? error = jsonDecode(response.body)['error'];
      if (error != null) showSnack(error, false);
      await playlist.load(force: true);
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
        body: jsonEncode({'playlistId': playlist.url, 'videoId': id}),
      );
      String? error = jsonDecode(response.body)['error'];
      showSnack(error ?? '${l['Added']} $title', error == null);
      await playlist.load(force: true);
    }
  }
}
