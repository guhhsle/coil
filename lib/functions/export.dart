import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import '../data.dart';
import '../functions/other.dart';
import '../pages/user_playlists.dart';
import '../playlist/playlist.dart';
import '../template/data.dart';
import '../template/functions.dart';

//BULK INDICATES ONE BIG FILE
Future<void> exportUser(bool bulk) async {
  playlists = [];
  showSnack('Loading', true);
  await fetchUserPlaylists(true);
  var futures = <Future>[];
  for (int i = 0; i < userPlaylists.value.length; i++) {
    futures.add(exportPlaylist(i, null));
  }
  await Future.wait(futures);
  for (int i = 0; i < playlists.length; i++) {
    try {
      await writeFile(
        bulk ? 'playlists.json' : '${playlists[i]['name']}.json',
        jsonEncode({
          'format': 'Piped',
          'version': 1,
          'playlists': bulk ? playlists : [playlists[i]],
        }),
      );
    } catch (e) {
      showSnack('$e', false);
    }
    if (bulk) i = playlists.length;
  }
}

List<Map> playlists = [];
//TEMPORARY VARIABLE FOR SAVING USER PLAYLISTS

Future<void> exportPlaylist(int i, Playlist? list) async {
  List<String> videos = [];
  list ??= await Playlist.load(userPlaylists.value[i]['id'], [1, 2]);
  for (int j = 0; j < list.list.length; j++) {
    videos.add('https://youtube.com${list.list[j].id}');
  }
  playlists.add({
    'name': formatName(list.name),
    'type': 'playlist',
    'visibility': 'private',
    'videos': videos,
  });
}

Future<void> exportOther(Playlist list) async {
  playlists = [];
  await exportPlaylist(0, list);
  try {
    await writeFile(
      '${playlists[0]['name']}.json',
      jsonEncode({
        'format': 'Piped',
        'version': 1,
        'playlists': playlists,
      }),
    );
  } catch (e) {
    showSnack('$e', false);
  }
}

Future<void> exportCache() async {
  File file = File('${pf['appDirectory']}/playlists.json');
  await writeFile('playlists.json', await file.readAsString());

  file = File('${pf['appDirectory']}/subscriptions.json');
  await writeFile('subscriptions.json', await file.readAsString());

  file = File('${pf['appDirectory']}/100raw.json');
  await writeFile('100raw.json', await file.readAsString());

  file = File('${pf['appDirectory']}/Bookmarks.json');
  await writeFile('Bookmarks.json', await file.readAsString());

  for (Map userPlaylist in userPlaylists.value) {
    String name = '${formatUrl(userPlaylist['id'])}.json';
    file = File('${pf['appDirectory']}/$name');
    await writeFile(name, await file.readAsString());
  }
}

Future<void> importCache() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    List<File> files = result!.paths.map((path) => File(path!)).toList();
    for (File backedFile in files) {
      File cacheFile = File('${pf['appDirectory']}/${basename(backedFile.path)}');
      cacheFile.writeAsBytes(await backedFile.readAsBytes());
    }
  } catch (e) {
    showSnack('$e', false);
  }
}
