import 'package:audio_service/audio_service.dart';
import '../data.dart';
import 'package:flutter/material.dart';

import '../functions/song.dart';
import '../http/account.dart';
import 'song_tile.dart';

class Subscriptions extends StatelessWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: feed,
      child: ValueListenableBuilder<List>(
        valueListenable: userSubscriptions,
        builder: (context, snap, widget) {
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
