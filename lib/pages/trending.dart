import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../widgets/song_tile.dart';
import '../template/data.dart';
import '../media/media.dart';
import '../countries.dart';
import '../data.dart';
import 'dart:convert';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: trending,
      child: ValueListenableBuilder(
        valueListenable: trendingVideos,
        builder: (context, snap, child) => ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: snap.length,
          physics: scrollPhysics,
          itemBuilder: (context, i) => SongTile(i: i, list: snap),
        ),
      ),
    );
  }
}

Future<void> trending() async {
  if (!Pref.instance.value.contains('.')) return;
  Response response = await get(Uri.https(Pref.instance.value, 'trending', {
    'region': countries.keys.elementAt(
      countries.values.toList().indexOf(Pref.location.value),
    ),
  }));
  List result = jsonDecode(utf8.decode(response.bodyBytes));
  trendingVideos.value = result.map((map) => Media.from(map)).toList();
}
