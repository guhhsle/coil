import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../widgets/song_tile.dart';
import '../template/data.dart';
import '../media/media.dart';
import '../data.dart';

Future<void> fetchFeed() async {
  try {
    if (Pref.token.value == '') return;
    Response response = await get(Uri.https(Pref.authInstance.value, 'feed', {
      'authToken': Pref.token.value,
    }));
    List result = jsonDecode(utf8.decode(response.bodyBytes));
    userFeed.setList(result.map((map) {
      return Media.from(map: map, queue: userFeed);
    }));
  } catch (e) {
    debugPrint('Couldnt fetch feed: $e');
  }
}

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchFeed,
      child: ListenableBuilder(
        listenable: userFeed,
        builder: (context, widget) => ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: userFeed.length,
          physics: scrollPhysics,
          itemBuilder: (context, i) => SongTile(media: userFeed[i]),
        ),
      ),
    );
  }
}
