import 'dart:io';

import 'package:coil/data.dart';
import 'package:coil/media/map.dart';
import 'package:coil/media/media.dart';

import '../functions/other.dart';
import '../playlist/playlist.dart';

extension MediaCache on Media {
  Future<void> forceAddBackup(
    String url, {
    bool top = false,
  }) async {
    Playlist local = await Playlist.fromStorage(url).onError(
      (err, stackTrace) => Playlist.fromString(url),
    );
    local.name = t(url);
    if (top) {
      (local.raw['relatedStreams'] as List).insert(0, toMap());
    } else {
      local.raw['relatedStreams'].add(toMap());
    }
    await local.backup();
    refreshList();
  }

  Future<void> forceRemoveBackup(
    String url, {
    bool first = true,
  }) async {
    Playlist local = await Playlist.fromStorage(url);
    late int index;
    if (first) {
      index = local.raw['relatedStreams'].indexWhere((e) => e['url'] == id);
    } else {
      index = local.raw['relatedStreams'].lastIndexWhere((e) => e['url'] == id);
    }
    if (index != -1) local.raw['relatedStreams'].removeAt(index);
    if ((local.raw['relatedStreams'] as List).isEmpty) {
      await File('${pf['appDirectory']}/$url.json').delete();
    } else {
      local.name = t(url);
    }
    await local.backup();
    refreshList();
  }

  Future<void> addTo100() async {
    await forceAddBackup('100raw', top: true);
    Playlist hundred = await Playlist.fromStorage('100raw');
    Map<String, int> map = {};
    List listRaw = hundred.raw['relatedStreams'];
    if (listRaw.length > 100) listRaw.removeLast();
    await hundred.backup();

    Playlist formatted = await Playlist.fromStorage('100').onError(
      (err, stackTrace) => Playlist.fromString('100'),
    );
    List list = formatted.raw['relatedStreams'] = hundred.raw['relatedStreams'].toList();

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
