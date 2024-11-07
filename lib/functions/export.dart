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
  final fileNames = userPlaylists.value.map((p) => p.url).toList();
  fileNames.addAll(['playlists', 'subscriptions', '100raw', 'Bookmarks']);

  for (final fileName in fileNames) {
    try {
      final file = File('${Pref.appDirectory.value}/$fileName.json');
      await writeFile('$fileName.json', await file.readAsString());
    } catch (e) {
      showSnack('$e', false);
    }
  }
  showSnack('Done', true);
}

Future<void> importCache() async {
  try {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    final files = result!.paths.map((path) => File(path!));
    for (final file in files) {
      await file.copy('${Pref.appDirectory.value}/${basename(file.path)}');
    }
    fetchAll();
    showSnack('Done', true);
  } catch (e) {
    showSnack('$e', false);
  }
}
