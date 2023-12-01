import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../services/playlist.dart';
import '../services/song.dart';
import 'song_tile.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: trending,
      child: ValueListenableBuilder<List>(
        valueListenable: trendingVideos,
        builder: (context, snap, child) {
          List<MediaItem> list = [];
          for (var q = 0; q < snap.length; q++) {
            list.add(mapToMedia(snap[q]));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            itemCount: list.length,
            physics: scrollPhysics,
            itemBuilder: (context, i) => SongTile(i: i, list: list),
          );
        },
      ),
    );
  }
}
