import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

import '../data.dart';
import '../http/playlist.dart';
import 'playlist.dart';

extension PlaylistHTTP on Playlist {
  Future<void> rename(String newName) async {
    if (pf['token'] == '') return;
    await post(
      Uri.https(pf['authInstance'], 'user/playlists/rename'),
      headers: {'Authorization': pf['token']},
      body: jsonEncode({
        'playlistId': url,
        'newName': newName,
      }),
    );
    unawaited(fetchUserPlaylists(true));
  }

  Future<void> delete() async {
    if (pf['token'] == '') return;
    await post(
      Uri.https(pf['authInstance'], 'user/playlists/delete'),
      headers: {'Authorization': pf['token']},
      body: jsonEncode({'playlistId': url}),
    );
    await fetchUserPlaylists(true);
  }
}
