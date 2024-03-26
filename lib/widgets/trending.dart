import 'package:flutter/material.dart';

import '../data.dart';
import '../http/playlist.dart';
import '../media/media.dart';
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
          List<Media> list = [];
          for (var q = 0; q < snap.length; q++) {
            list.add(Media.from(snap[q]));
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
