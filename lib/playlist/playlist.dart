import 'package:flutter/material.dart';
import 'cache.dart';
import 'http.dart';
import 'map.dart';
import '../template/functions.dart';
import '../media/media_queue.dart';
import '../functions/other.dart';
import '../data.dart';

class Playlist extends MediaQueue {
  String name = '', uploader = 'Local';
  String url, thumbnail = '';
  Map raw = {'relatedStreams': <Map>[]};
  List<int> path = [0, 1];

  Playlist(this.url) {
    url = formatUrl(url);
    name = t(url);
  }

  static Playlist fromMap(Map map) {
    final playlist = Playlist(map['id'] ?? map['url']);
    playlist.loadFromMap(map);
    return playlist;
  }

  Future<void> load({int timeTried = 0, bool force = false}) async {
    for (int i in path) {
      try {
        if (i == 0) return await loadFromInstance(Pref.instance.value);
        if (i == 1) return await loadFromInstance(Pref.authInstance.value);
        if (i == 2 && !force) return await loadFromCache();
      } catch (e) {
        debugPrint('Couldnt load playlist $name on $i: $e');
      }
    }
    if (timeTried < 4) return load(timeTried: ++timeTried);
  }

  bool isCacheOnly() => playlistIsCacheOnly(name);
}

const userFiles = ['Bookmarks', '100', '100raw'];

bool playlistIsCacheOnly(String url) {
  if (Pref.token.value == '') return true;
  if (userFiles.contains(url)) return true;
  return false;
}
