import 'dart:convert';
import 'dart:io';
import 'playlist.dart';
import 'map.dart';
import 'package:flutter/material.dart';
import '../pages/user_playlists.dart';
import '../functions/other.dart';
import '../media/media.dart';
import '../media/map.dart';
import '../data.dart';

extension PlaylistCache on Playlist {
  Future<void> backup() async {
    if (!userFiles.contains(url) &&
        userPlaylists.value.indexWhere((p) => p.url == url) == -1 &&
        !Pref.bookmarks.value.contains(url)) return;
    File file = File('${Pref.appDirectory.value}/${formatUrl(url)}.json');

    print(name);
    List<Media> songs = [];
    if (user) {
      songs = list.reversed.toList();
    } else {
      songs = list.toList();
    }
    final formatted = {
      'name': name,
      'thumbnailUrl': thumbnail,
      'uploader': uploader,
      'relatedStreams': songs.map((song) {
        return song.toMap();
      }).toList(),
    };
    await file.writeAsString(jsonEncode(formatted));
    notify();
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

  Future<void> forceAddMediaToCache(
    Media media, {
    bool top = false,
  }) async {
    await load().onError(
      (err, stackTrace) => debugPrint('Error adding media $err'),
    );
    if (user) top = !top;
    if (top) {
      list.insert(0, media);
    } else {
      list.add(media);
    }
    await backup();
  }

  Future<void> forceRemoveMediaFromCache(
    Media media, {
    bool first = true,
  }) async {
    await load();
    int index = -1;
    if (user) first = !first;
    if (first) {
      index = list.indexWhere((m) => m.id == media.id);
    } else {
      index = list.lastIndexWhere((m) => m.id == media.id);
    }
    if (index == -1) return;
    list.removeAt(index);
    if (isEmpty) await File('${Pref.appDirectory.value}/$url.json').delete();
    print('INDEX : $index');
    await backup();
  }
}
