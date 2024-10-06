import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data.dart';
import '../media/media.dart';
import '../template/data.dart';
import '../widgets/song_tile.dart';

Future<void> fetchFeed() async {
  if (Pref.token.value == '') return;
  Response response = await get(
    Uri.https(Pref.authInstance.value, 'feed', {'authToken': Pref.token.value}),
  );
  List result = jsonDecode(utf8.decode(response.bodyBytes));
  userFeed.value = result.map((map) => Media.from(map)).toList();
}

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchFeed,
      child: ValueListenableBuilder(
        valueListenable: userFeed,
        builder: (context, snap, widget) => ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: snap.length,
          physics: scrollPhysics,
          itemBuilder: (context, i) => SongTile(i: i, list: snap),
        ),
      ),
    );
  }
}
