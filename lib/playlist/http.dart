import 'package:http/http.dart';
import 'dart:convert';
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
    backup();
    fetchUserPlaylists(true);
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

  Future<void> loadFromInternet(bool auth) async {
    final instance = auth ? Pref.authInstance.value : Pref.instance.value;
    final response = await get(Uri.https(instance, 'playlists/$url'));
    loadFromMap(jsonDecode(utf8.decode(response.bodyBytes)));
    backup();
  }

  Future<void> create() async {
    if (Pref.token.value == '') {
      name = url;
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
