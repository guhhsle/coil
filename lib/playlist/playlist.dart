import 'package:flutter/material.dart';
import 'cache.dart';
import 'http.dart';
import '../template/functions.dart';
import '../media/media_queue.dart';
import '../functions/other.dart';
import '../data.dart';

class Playlist extends MediaQueue {
  String name = '', uploader = 'Local';
  String url, thumbnail = '';
  Map raw = {'relatedStreams': <Map>[]};

  Playlist(this.url) {
    url = formatUrl(url);
    name = t(url);
  }

  Future<void> load(
    List<int> path, {
    int timeTried = 0,
  }) async {
    for (int i in path) {
      try {
        if (i == 2) return await loadFromCache();
        return await loadFromInternet(i == 1);
      } catch (e) {
        debugPrint('Couldnt load playlist $i:');
        debugPrint(e.toString());
      }
    }
    if (timeTried < 4) return load(path, timeTried: ++timeTried);
  }

  bool isCacheOnly() => playlistIsCacheOnly(name);
}

const userFiles = ['Bookmarks', '100', '100raw'];

bool playlistIsCacheOnly(String url) {
  if (Pref.token.value == '') return true;
  if (userFiles.contains(url)) return true;
  return false;
}
