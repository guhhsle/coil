import 'dart:convert';
import 'dart:io';

import 'package:coil/playlist/playlist.dart';

import '../data.dart';
import '../functions/other.dart';
import 'map.dart';

const List<String> userFiles = ['Bookmarks', '100', '100raw'];

extension PlaylistCache on Playlist {
  Future<void> backup() async {
    if (!userFiles.contains(url) &&
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
}
