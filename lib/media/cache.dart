import 'package:flutter/material.dart';
import 'media.dart';
import '../playlist/playlist.dart';
import '../playlist/cache.dart';

extension MediaCache on Media {
  Future<void> addTo100() async {
    await Playlist('100raw').forceAddMediaToCache(this, top: true);
    final hundred = Playlist('100raw');
    await hundred.load([2]);
    Map<String, int> map = {};
    List listRaw = hundred.raw['relatedStreams'];
    if (listRaw.length > 100) listRaw.removeLast();
    await hundred.backup();

    final formatted = Playlist('100');
    await formatted.load([2]).onError(
      (err, stackTrace) => debugPrint('Error formatting $err'),
    );
    List list = formatted.raw['relatedStreams'] =
        hundred.raw['relatedStreams'].toList();

    for (Map item in list) {
      if (map.containsKey(item['url'])) {
        map[item['url']] = map[item['url']]! + 1;
      } else {
        map.addAll({item['url']: 1});
      }
    }
    list.sort(
      (a, b) => map[b['url']]!.compareTo(map[a['url']]!),
    );
    for (int i = 0; i < list.length; i++) {
      if (map[list[i]['url']]! > 1) {
        map[list[i]['url']] = map[list[i]['url']]! - 1;
        list.removeAt(i);
        i--;
      }
    }
    await formatted.backup();
  }
}
