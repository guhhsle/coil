import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data.dart';
import 'song_tile.dart';

class LocalSongs extends StatefulWidget {
  const LocalSongs({super.key});

  @override
  LocalSongsState createState() => LocalSongsState();
}

Future<void> getLocal() async {
  await Permission.storage.request();
  await Permission.audio.request();
  if (Platform.isAndroid && await Directory(pf['musicFolder']).exists()) {
    localMusic.value = Directory(pf['musicFolder']).listSync();
  }
}

class LocalSongsState extends State<LocalSongs> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getLocal,
      child: ValueListenableBuilder<List>(
        valueListenable: localMusic,
        builder: (context, data, child) {
          List<MediaItem> list = [];
          for (int i = 0; i < localMusic.value.length; i++) {
            String songPath = localMusic.value[i].path.replaceAll('.m4a', '').replaceAll('.mp3', '');
            if (localMusic.value[i].path.endsWith('.m4a') || localMusic.value[i].path.endsWith('.mp3')) {
              list.add(
                MediaItem(
                  title: basename(songPath),
                  artist: '',
                  id: localMusic.value[i].path,
                  extras: {'url': localMusic.value[i].path, 'offline': true},
                ),
              );
            }
          }
          list.sort((item1, item2) {
            return item1.title.compareTo(item2.title);
          });
          return ListView.builder(
            itemCount: list.length,
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            physics: scrollPhysics,
            itemBuilder: (context, i) {
              return SongTile(i: i, list: list);
            },
          );
        },
      ),
    );
  }
}
