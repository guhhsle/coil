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
  for (final map in userPlaylists.value) {
    showSnack('Loading...', true);
    final playlist = Playlist(map['id']);
    playlist.name = map['name'];
    await playlist.load([1, 2]);
    await playlist.exportLoaded();
  }
  showSnack('Completed', true);
}

extension Export on Playlist {
  Map get exportMap {
    return {
      'name': formatName(name),
      'type': 'playlist',
      'visibility': 'private',
      'videos': list.map((m) => 'https://youtube.com${m.id}').toList(),
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

  for (Map userPlaylist in userPlaylists.value) {
    String name = '${formatUrl(userPlaylist['id'])}.json';
    file = File('${Pref.appDirectory.value}/$name');
    await writeFile(name, await file.readAsString());
  }
}

Future<void> importCache() async {
  try {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final files = result!.paths.map((path) => File(path!)).toList();
    for (File backedFile in files) {
      File cacheFile =
          File('${Pref.appDirectory.value}/${basename(backedFile.path)}');
      cacheFile.writeAsBytes(await backedFile.readAsBytes());
    }
  } catch (e) {
    showSnack('$e', false);
  }
}
