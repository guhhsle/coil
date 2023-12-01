import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:coil/data.dart';
import 'package:coil/functions.dart';
import 'package:coil/services/song.dart';

class Playlist {
  String url, thumbnail, name, uploader;
  Map raw;
  int items;
  List<MediaItem> list;

  Playlist({
    required this.url,
    required this.name,
    required this.list,
    required this.uploader,
    required this.items,
    required this.thumbnail,
    required this.raw,
  });

  static List<MediaItem> listFromMap(Map json, String url) {
    List playlist = json['relatedStreams'] ?? [];
    List<MediaItem> list = [];
    for (var i = 0; i < playlist.length; i++) {
      int index = userPlaylists.value.indexWhere((el) => el['id'] == url);
      if (url == 'Bookmarks') index++;
      if (pf['reverse'] && index >= 0) {
        list.insert(
          0,
          mapToMedia(
            playlist[i],
            playlist: index >= 0 ? url : null,
            i: i,
          ),
        );
      } else {
        list.add(mapToMedia(
          playlist[i],
          playlist: index >= 0 ? url : null,
          i: i,
        ));
      }
    }
    return list;
  }

  static Playlist fromJson(Map json, String url) {
    return Playlist(
      url: url,
      name: json['name'] ?? 'NAME',
      thumbnail: json['thumbnailUrl'] ?? '',
      list: listFromMap(json, url),
      uploader: json['uploader'] ?? json['uploaderName'] ?? 'UPLOADER',
      items: json['videos'] ?? 404,
      raw: json,
    );
  }

  String fromattedName() {
    return name.contains('Album ') ? name.replaceRange(0, 8, '') : name;
  }

  static List<String> userFiles = [
    'Bookmarks',
    '100',
    '100raw',
  ];

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

  static Future<Playlist> fromStorage(String url) async {
    File file = File('${pf['appDirectory']}/${formatUrl(url)}.json');
    if (!await file.exists()) throw Error();
    Map json = jsonDecode(await file.readAsString());
    return Playlist.fromJson(json, url);
  }

  static Playlist fromString(String url) {
    return Playlist(
      url: url,
      thumbnail: '',
      list: [],
      uploader: 'Local',
      items: 0,
      name: t(url),
      raw: {'relatedStreams': []},
    );
  }
}
