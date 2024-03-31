import 'dart:convert';
import 'dart:io';

import 'package:coil/playlist/playlist.dart';

import '../data.dart';
import '../functions/other.dart';
import 'map.dart';

extension PlaylistCache on Playlist {
  Future<void> backup() async {
    if (!isCacheOnly() &&
        userPlaylists.value.indexWhere((el) => el['id'] == url) == -1 &&
        !pf['bookmarks'].contains(url)) return;
    File file = File('${pf['appDirectory']}/${formatUrl(url)}.json');
    Map formatted = {
      'name': name,
      'thumbnailUrl': thumbnail,
      'uploader': uploader,
      'videos': items,
      'relatedStreams': <Map>[],
    };
    for (Map song in raw['relatedStreams']) {
      formatted['relatedStreams'].add({
        'url': song['url'].replaceAll('/watch?v=', ''),
        'title': song['title'],
        'thumbnail': song['thumbnail'],
        'uploaderName': song['uploaderName'].replaceAll(' - Topic', ''),
        'uploaderUrl': song['uploaderUrl'],
      });
    }
    await file.writeAsString(jsonEncode(formatted));
  }

  static Future<Playlist> from(String url) async {
    File file = File('${pf['appDirectory']}/${formatUrl(url)}.json');
    if (!await file.exists()) throw Error();
    Map json = jsonDecode(await file.readAsString());
    return PlaylistMap.from(json, url);
  }

  Future<void> renameBackupTo(String newName) async {
    name = newName;
    await backup();
    await removeFromCache();
    await addToCache();
  }

  Future<void> removeFromCache() async {
    File file = File('${pf['appDirectory']}/playlists.json');
    List list = jsonDecode(await file.readAsString());
    list.removeWhere((map) => map['id'] == url);
    await file.writeAsString(jsonEncode(list));
  }

  Future<void> addToCache() async {
    File file = File('${pf['appDirectory']}/playlists.json');
    List list = jsonDecode(await file.readAsString());
    list.add({
      'id': url,
      'name': name,
      'thumbnail': thumbnail,
      'videos': items,
    });
    await file.writeAsString(jsonEncode(list));
  }
}
