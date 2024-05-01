import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import '../data.dart';
import '../pages/user_playlists.dart';
import '../template/functions.dart';
import 'cache.dart';
import 'map.dart';
import 'playlist.dart';

extension PlaylistHTTP on Playlist {
  Future<void> rename(String newName) async {
    if (isCacheOnly()) {
      await renameBackupTo(newName);
    } else {
      await post(
        Uri.https(pf['authInstance'], 'user/playlists/rename'),
        headers: {'Authorization': pf['token']},
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
        Uri.https(pf['authInstance'], 'user/playlists/delete'),
        headers: {'Authorization': pf['token']},
        body: jsonEncode({'playlistId': url}),
      );
    }
    await fetchUserPlaylists(true);
  }

  static Future<Playlist> from(String url, bool auth) async {
    Uri u = Uri.https(pf[auth ? 'authInstance' : 'instance'], 'playlists/$url');
    return PlaylistMap.from(
      jsonDecode(utf8.decode((await get(u)).bodyBytes)),
      url,
    )..backup();
  }

  Future<void> create() async {
    if (pf['token'] == '') {
      url = '$name-${DateTime.now()}';
      await addToCache();
      await backup();
    } else {
      try {
        await post(
          Uri.https(pf['authInstance'], 'user/playlists/create'),
          body: jsonEncode({'name': name}),
          headers: {'Authorization': pf['token']},
        );
      } catch (e) {
        showSnack('$e', false);
      }
    }
    await fetchUserPlaylists(true);
  }
}
