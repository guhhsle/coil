import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../widgets/song_tile.dart';
import '../template/data.dart';
import '../media/media.dart';
import '../countries.dart';
import '../data.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: trending,
      child: ListenableBuilder(
        listenable: trendingVideos,
        builder: (context, child) => ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: trendingVideos.length,
          physics: scrollPhysics,
          itemBuilder: (context, i) => SongTile(
            media: trendingVideos[i],
          ),
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
  trendingVideos.setList(result.map((map) {
    return Media.from(map: map, queue: trendingVideos);
  }));
}
