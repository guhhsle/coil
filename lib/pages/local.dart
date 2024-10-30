import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../widgets/song_tile.dart';
import '../template/data.dart';
import '../media/media.dart';
import '../data.dart';

class LocalSongs extends StatelessWidget {
  const LocalSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getLocal,
      child: ListenableBuilder(
        listenable: localMusic,
        builder: (context, child) => ListView.builder(
          itemCount: localMusic.length,
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          physics: scrollPhysics,
          itemBuilder: (context, i) => SongTile(media: localMusic[i]),
        ),
      ),
    );
  }
}

Future<void> getLocal() async {
  try {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.audio.request();
    }
    if (await Directory(Pref.musicFolder.value).exists()) {
      final files = Directory(Pref.musicFolder.value).listSync();
      localMusic.clear(notify: false);
      for (var file in files) {
        String songPath =
            file.path.replaceAll('.m4a', '').replaceAll('.mp3', '');
        if (file.path.endsWith('.m4a') || file.path.endsWith('.mp3')) {
          localMusic.add(
            Media(
              title: basename(songPath),
              id: file.path,
              audioUrl: file.path,
              offline: true,
              queue: localMusic,
            ),
            notify: false,
          );
        }
      }
      localMusic.sort(compare: (item1, item2) {
        return item1.title.compareTo(item2.title);
      });
    }
  } catch (e) {
    debugPrint('Couldnt load local: $e');
  }
}
