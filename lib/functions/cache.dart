import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:coil/functions/other.dart';

import '../data.dart';
import '../http/playlist.dart';
import '../playlist.dart';
import 'song.dart';

Future<void> refreshBookmarks() async {
  try {
    bookmarksPlaylist = await Playlist.fromStorage('Bookmarks');
  } catch (e) {
    bookmarksPlaylist = Playlist.fromJson(
      {
        "name": "Bookmarks",
        "thumbnailUrl": "",
        "uploader": "Local",
        "videos": 0,
        "relatedStreams": <Map>[],
      },
      'Bookmarks',
    )..backup();
  }
  refreshPlaylist.value = !refreshPlaylist.value;
}

Future<void> fetchBookmarks() async {
  List<Playlist> tempBookmarks = [];
  List<Future> futures = [];

  refreshBookmarks();

  for (int i = 0; i < pf['bookmarks'].length; i++) {
    futures.add(loadPlaylist(pf['bookmarks'][i], [2, 0, 1]).then(
      (val) => tempBookmarks.add(val),
    ));
  }
  await Future.wait(futures);
  bookmarks.value = tempBookmarks;
}

Future<void> forceAddBackup(
  MediaItem item,
  String url, {
  bool top = false,
}) async {
  Playlist local = await Playlist.fromStorage(url).onError(
    (err, stackTrace) => Playlist.fromString(url),
  );
  local.name = t(url);
  if (top) {
    (local.raw['relatedStreams'] as List).insert(0, mediaToMap(item));
  } else {
    local.raw['relatedStreams'].add(mediaToMap(item));
  }
  await local.backup();
  await refreshBookmarks();
}

Future<void> forceRemoveBackup(
  MediaItem item,
  String url, {
  bool first = true,
}) async {
  Playlist local = await Playlist.fromStorage(url);
  late int index;
  if (first) {
    index = local.raw['relatedStreams'].indexWhere((e) => e['url'] == item.id);
  } else {
    index = local.raw['relatedStreams'].lastIndexWhere((e) => e['url'] == item.id);
  }
  if (index != -1) local.raw['relatedStreams'].removeAt(index);
  if ((local.raw['relatedStreams'] as List).isEmpty) {
    await File('${pf['appDirectory']}/$url.json').delete();
  } else {
    local.name = t(url);
  }
  await local.backup();
  await refreshBookmarks();
}

Future<void> addTo100(MediaItem item) async {
  await forceAddBackup(item, '100raw', top: true);
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
