import 'dart:convert';
import 'dart:io';

import 'package:coil/data.dart';
import 'package:http/http.dart';

import '../functions/other.dart';
import '../media/media.dart';

class Playlist {
  String url, thumbnail, name, uploader;
  Map raw;
  int items;
  List<Media> list;

  Playlist({
    required this.url,
    required this.name,
    required this.list,
    required this.uploader,
    required this.items,
    required this.thumbnail,
    required this.raw,
  });

  static List<Media> listFromMap(Map json, String url) {
    List playlist = json['relatedStreams'] ?? [];
    List<Media> list = [];
    for (var i = 0; i < playlist.length; i++) {
      int index = userPlaylists.value.indexWhere((el) => el['id'] == url);
      if (url == 'Bookmarks') index++;
      if (pf['reverse'] && index >= 0) {
        list.insert(
          0,
          Media.from(
            playlist[i],
            playlist: index >= 0 ? url : null,
            i: i,
          ),
        );
      } else {
        list.add(Media.from(
          playlist[i],
          playlist: index >= 0 ? url : null,
          i: i,
        ));
      }
    }
    return list;
  }

  static Playlist fromJson(Map json, String url) {
    List<Media> list = listFromMap(json, url);
    return Playlist(
      url: url,
      name: json['name'] ?? 'NAME',
      thumbnail: json['thumbnailUrl'] ?? '',
      list: list,
      uploader: json['uploader'] ?? json['uploaderName'] ?? 'UPLOADER',
      items: list.length,
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

  static Future<Playlist> load(
    String url,
    List<int> path, {
    int timeTried = 0,
  }) async {
    url = formatUrl(url);
    Playlist? list;
    for (int i in path) {
      try {
        if (i == 2) {
          list = await Playlist.fromStorage(url);
          return list;
        } else {
          Uri u = Uri.https(pf[i == 0 ? 'instance' : 'authInstance'], 'playlists/$url');
          list = Playlist.fromJson(jsonDecode(utf8.decode((await get(u)).bodyBytes)), url)..backup();
          return list;
        }
      } catch (e) {
        //
      }
    }
    if (timeTried < 4 && list == null) {
      return load(
        url,
        path,
        timeTried: ++timeTried,
      );
    } else {
      return list!;
    }
  }
}
