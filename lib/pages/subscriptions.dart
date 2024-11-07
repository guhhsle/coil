import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import '../widgets/playlist_tile.dart';
import '../playlist/playlist.dart';
import '../template/data.dart';
import '../data.dart';

Future<void> fetchSubscriptions(bool force) async {
  try {
    List list = [];
    File file = File('${Pref.appDirectory.value}/subscriptions.json');
    if (force && Pref.token.value != '') {
      Response response = await get(
        Uri.https(Pref.authInstance.value, 'subscriptions'),
        headers: {'Authorization': Pref.token.value},
      );
      list = jsonDecode(utf8.decode(response.bodyBytes));
      await file.writeAsBytes(response.bodyBytes);
    } else {
      list = jsonDecode(await file.readAsString());
      if (list.isEmpty && !force) fetchSubscriptions(true);
    }
    userSubscriptions.value = list;
  } catch (e) {
    if (force) fetchSubscriptions(false);
  }
}

class Subscriptions extends StatelessWidget {
  const Subscriptions({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => fetchSubscriptions(true),
      child: ValueListenableBuilder(
        valueListenable: userSubscriptions,
        builder: (context, snap, widget) => ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: snap.length,
          physics: scrollPhysics,
          itemBuilder: (context, i) => PlaylistTile(
            ArtistPlaylist.fromMap(snap[i]),
          ),
        ),
      ),
    );
  }
}
