import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data.dart';
import '../template/data.dart';
import '../widgets/playlist_tile.dart';

Future<void> fetchSubscriptions(bool force) async {
  try {
    List list = [];
    File file = File('${pf['appDirectory']}/subscriptions.json');
    if (force && pf['token'] != '') {
      Response response = await get(
        Uri.https(pf['authInstance'], 'subscriptions'),
        headers: {'Authorization': pf['token']},
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
            info: snap[i],
            playlist: false,
            path: const [0, 1],
          ),
        ),
      ),
    );
  }
}
