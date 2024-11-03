import 'dart:convert';
import 'dart:io';
import 'playlist.dart';
import 'map.dart';
import 'package:flutter/material.dart';
import '../pages/user_playlists.dart';
import '../functions/other.dart';
import '../template/prefs.dart';
import '../media/media.dart';
import '../media/map.dart';
import '../data.dart';

extension PlaylistCache on Playlist {
  Future<void> backup() async {
    if (!userFiles.contains(url) &&
        userPlaylists.value.indexWhere((el) => el['id'] == url) == -1 &&
        !Pref.bookmarks.value.contains(url)) return;
    File file = File('${Pref.appDirectory.value}/${formatUrl(url)}.json');
    Map formatted = {
      'name': name,
      'thumbnailUrl': thumbnail,
      'uploader': uploader,
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

  Future<void> loadFromCache() async {
    File file = File('${Pref.appDirectory.value}/$url.json');
    if (!await file.exists()) throw Exception('$name is not cached');
    loadFromMap(jsonDecode(await file.readAsString()));
  }

  Future<void> renameBackupTo(String newName) async {
    name = newName;
    await backup();
    await removeBackup();
    await addToCache();
  }

  Future<void> removeBackup() async {
    File file = File('${Pref.appDirectory.value}/playlists.json');
    List list = jsonDecode(await file.readAsString());
    list.removeWhere((map) => map['id'] == url);
    await file.writeAsString(jsonEncode(list));
  }

  Future<void> addToCache() async {
    File file = File('${Pref.appDirectory.value}/playlists.json');
    if (!await file.exists()) {
      await file.writeAsString('[]');
    }
    List list = jsonDecode(await file.readAsString());
    list.add({
      'id': url,
      'name': name,
      'thumbnail': thumbnail,
    });
    await file.writeAsString(jsonEncode(list));
    await fetchUserPlaylists(false);
  }

  Future<void> forceAddMediaToCache(Media media, {bool top = false}) async {
    await load([2]).onError(
      (err, stackTrace) => debugPrint('Error adding media $err'),
    );
    if (top) {
      (raw['relatedStreams'] as List).insert(0, media.toMap());
    } else {
      raw['relatedStreams'].add(media.toMap());
    }
    await backup();
    Preferences.notify();
  }

  Future<void> forceRemoveMediaFromCache(Media media,
      {bool first = true}) async {
    await load([2]);
    late int index;
    if (first) {
      index = raw['relatedStreams'].indexWhere((e) => e['url'] == media.id);
    } else {
      index = raw['relatedStreams'].lastIndexWhere((e) => e['url'] == media.id);
    }
    if (index != -1) raw['relatedStreams'].removeAt(index);
    if ((raw['relatedStreams'] as List).isEmpty) {
      await File('${Pref.appDirectory.value}/$url.json').delete();
    }
    await backup();
    Preferences.notify();
  }
}
