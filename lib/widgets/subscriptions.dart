import '../data.dart';
import 'package:flutter/material.dart';

import '../http/account.dart';
import '../song.dart';
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
          List<Song> list = [];
          for (var q = 0; q < snap.length; q++) {
            list.add(Song.from(snap[q]));
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
