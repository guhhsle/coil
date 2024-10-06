import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'playlist.dart';
import 'cache.dart';
import 'map.dart';
import '../pages/user_playlists.dart';
import '../template/functions.dart';
import '../data.dart';

extension PlaylistHTTP on Playlist {
  Future<void> rename(String newName) async {
    if (isCacheOnly()) {
      await renameBackupTo(newName);
    } else {
      await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/rename'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({
          'playlistId': url,
          'newName': newName,
        }),
      );
    }
    name = newName;
    unawaited(backup());

    unawaited(fetchUserPlaylists(true));
  }

  Future<void> delete() async {
    if (isCacheOnly()) {
      await removeBackup();
    } else {
      await post(
        Uri.https(Pref.authInstance.value, 'user/playlists/delete'),
        headers: {'Authorization': Pref.token.value},
        body: jsonEncode({'playlistId': url}),
      );
    }
    await fetchUserPlaylists(true);
  }

  static Future<Playlist> from(String url, bool auth) async {
    Uri u = Uri.https(Pref.instance.value, 'playlists/$url');
    if (auth) {
      u = Uri.https(Pref.authInstance.value, 'playlists/$url');
    }
    return PlaylistMap.from(
      jsonDecode(utf8.decode((await get(u)).bodyBytes)),
      url,
    )..backup();
  }

  Future<void> create() async {
    if (Pref.token.value == '') {
      url = '$name-${DateTime.now()}';
      await addToCache();
      await backup();
    } else {
      try {
        await post(
          Uri.https(Pref.authInstance.value, 'user/playlists/create'),
          body: jsonEncode({'name': name}),
          headers: {'Authorization': Pref.token.value},
        );
      } catch (e) {
        showSnack('$e', false);
      }
    }
    await fetchUserPlaylists(true);
  }
}
