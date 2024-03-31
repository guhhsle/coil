import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../data.dart';
import '../http/playlist.dart';
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

    unawaited(fetchUserPlaylists(true));
  }

  Future<void> delete() async {
    if (isCacheOnly()) {
      await removeFromCache();
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
}
