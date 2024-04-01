import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../data.dart';
import '../media/media.dart';
import 'song_tile.dart';

Future<void> feed() async {
  if (pf['token'] == '') return;
  Response response = await get(
    Uri.https(pf['authInstance'], 'feed', {'authToken': pf['token']}),
  );
  List result = jsonDecode(utf8.decode(response.bodyBytes));
  userSubscriptions.value = result.map((map) => Media.from(map)).toList();
}

class Subscriptions extends StatelessWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: feed,
      child: ValueListenableBuilder(
        valueListenable: userSubscriptions,
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
