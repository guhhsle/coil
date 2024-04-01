import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data.dart';
import '../media/media.dart';
import 'song_tile.dart';

class LocalSongs extends StatelessWidget {
  const LocalSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getLocal,
      child: ValueListenableBuilder(
        valueListenable: localMusic,
        builder: (context, snap, child) => ListView.builder(
          itemCount: snap.length,
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          physics: scrollPhysics,
          itemBuilder: (context, i) => SongTile(i: i, list: snap),
        ),
      ),
    );
  }
}

Future<void> getLocal() async {
  if (Platform.isAndroid) {
    await Permission.storage.request();
    await Permission.audio.request();
  }
  if (await Directory(pf['musicFolder']).exists()) {
    final files = Directory(pf['musicFolder']).listSync();
    List<Media> list = [];
    for (var file in files) {
      String songPath = file.path.replaceAll('.m4a', '').replaceAll('.mp3', '');
      if (file.path.endsWith('.m4a') || file.path.endsWith('.mp3')) {
        list.add(
          Media(
            title: basename(songPath),
            id: file.path,
            audioUrl: file.path,
            offline: true,
          ),
        );
      }
    }
    list.sort((item1, item2) => item1.title!.compareTo(item2.title!));
    localMusic.value = list;
  }
}
