import 'dart:math';

import 'package:coil/playlist/http.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'dart:io';
import '../pages/user_playlists.dart';
import '../template/functions.dart';
import '../playlist/playlist.dart';
import '../functions/other.dart';
import '../data.dart';

Future<void> exportUser() async {
  await fetchUserPlaylists(true);
  for (final playlist in userPlaylists.value) {
    showSnack('Loading...', true);
    await playlist.load(force: true);
    await playlist.exportLoaded();
  }
  showSnack('Completed', true);
}

extension Export on Playlist {
  Map get exportMap {
    List<String> videos = list.map((m) {
      return 'https://youtube.com/${m.id}';
    }).toList();
    if (user) videos = videos.reversed.toList();
    return {
      'name': formatName(name),
      'type': 'playlist',
      'visibility': 'private',
      'videos': videos,
    };
  }

  Future<void> exportLoaded() async {
    try {
      await writeFile(
        '${exportMap['name']}.json',
        jsonEncode({
          'format': 'Piped',
          'version': 1,
          'playlists': [exportMap],
        }),
      );
    } catch (e) {
      showSnack('$e', false);
    }
  }
}

Future<void> exportCache() async {
  File file = File('${Pref.appDirectory.value}/playlists.json');
  await writeFile('playlists.json', await file.readAsString());

  file = File('${Pref.appDirectory.value}/subscriptions.json');
  await writeFile('subscriptions.json', await file.readAsString());

  file = File('${Pref.appDirectory.value}/100raw.json');
  await writeFile('100raw.json', await file.readAsString());

  file = File('${Pref.appDirectory.value}/Bookmarks.json');
  await writeFile('Bookmarks.json', await file.readAsString());

  for (final playlist in userPlaylists.value) {
    String name = '${playlist.url}.json';
    file = File('${Pref.appDirectory.value}/$name');
    await writeFile(name, await file.readAsString());
  }
}

Future<void> importCache() async {
  try {
    //TODO
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final files = result!.paths.map((path) => File(path!)).toList();
    for (final backedFile in files) {
      final url = cleanFileName(backedFile.path);
      File cacheFile = File('${Pref.appDirectory.value}/$url.json');
      cacheFile.writeAsBytes(await backedFile.readAsBytes());
      final imported = Playlist(url);
      imported.path = [2];
      await imported.load();
      await imported.create();
    }
  } catch (e) {
    showSnack('$e', false);
  }
}

String fileName(String unformattedPath) {
  final parts = unformattedPath.split('/');
  final name = parts.isNotEmpty ? parts.last : unformattedPath;
  return name.trim();
}

String cleanFileName(String unformattedPath) {
  final fullName = fileName(unformattedPath);
  final parts = fullName.split('.');
  final name = parts.isNotEmpty ? parts.first : fullName;
  return name.trim();
}
