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
      final files = Directory(Pref.musicFolder.value).listSync(recursive: true);
      localMusic.clear(notify: false);
      for (final file in files) {
        for (final extension in audioExtensions) {
          if (file.path.endsWith('.$extension')) {
            localMusic.add(
              Media(
                title: basename(file.path.replaceAll('.$extension', '')),
                audioUrl: file.path,
                queue: localMusic,
                offline: true,
                id: file.path,
              ),
              notify: false,
            );
            break;
          }
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

const audioExtensions = {'m4a', 'mp3'};
