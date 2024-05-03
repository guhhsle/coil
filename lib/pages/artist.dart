import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data.dart';
import '../functions/other.dart';
import '../template/custom_chip.dart';
import '../template/data.dart';
import '../widgets/frame.dart';
import 'subscriptions.dart';
import '../media/media.dart';
import '../widgets/playlist_tile.dart';
import '../widgets/song_tile.dart';

class PageArtist extends StatefulWidget {
  final String url;
  final String artist;

  const PageArtist({
    super.key,
    required this.url,
    required this.artist,
  });
  @override
  PageArtistState createState() => PageArtistState();
}

class PageArtistState extends State<PageArtist> {
  bool isSubscribed = false;
  String selectedHome = 'Videos';
  Map videos = {};
  Map playlists = {};
  final options = ['Videos', 'Other'];

  Future<void> unSubscribe() async {
    if (pf['token'] == '') {
      File file = File('${pf['appDirectory']}/subscriptions.json');
      List list = jsonDecode(await file.readAsString());
      if (isSubscribed) {
        list.removeWhere((e) => e['url'].contains(widget.url));
      } else {
        list.add({
          'url': videos['id'],
          'name': videos['name'],
          'avatar': videos['avatarUrl'],
          'verified': true,
        });
      }
      await file.writeAsString(jsonEncode(list));
      await fetchSubscriptions(false);
    } else {
      await post(
        Uri.https(pf['authInstance'], isSubscribed ? 'unsubscribe' : 'subscribe'),
        headers: {
          'Authorization': pf['token'],
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'channelId': videos['id']}),
      );
      await fetchSubscriptions(true);
    }
    setState(() {});
  }

  Future<void> loadContent() async {
    try {
      Response result = await get(Uri.https(pf['instance'], widget.url));
      videos = jsonDecode(utf8.decode(result.bodyBytes));
      setState(() {});
      result = await get(
        Uri.https(
          pf['instance'],
          'channels/tabs',
          {'data': (jsonDecode(result.body)['tabs'][0])['data']},
        ),
      );
      playlists = jsonDecode(utf8.decode(result.bodyBytes));
    } catch (e) {
      //INVALID CHANNEL
    }
    setState(() {});
  }

  @override
  void initState() {
    unawaited(loadContent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isSubscribed = userSubscriptions.value.indexWhere((e) => e['url'].contains(widget.url)) >= 0;
    return Frame(
      title: Text(formatName(widget.artist)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 64,
            child: ListView(
              physics: scrollPhysics,
              scrollDirection: Axis.horizontal,
              children: [
                for (String option in options)
                  CustomChip(
                    selected: selectedHome == option,
                    onSelected: (val) {
                      selectedHome = option;
                      setState(() {});
                    },
                    label: option,
                  ),
                CustomChip(
                  selected: isSubscribed,
                  showCheckmark: true,
                  onSelected: (val) => unSubscribe(),
                  label: '${videos['subscriberCount']}',
                )
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                late List list;
                if (selectedHome == 'Videos') {
                  list = videos['relatedStreams'] ?? [];
                } else {
                  list = playlists['content'] ?? [];
                }
                List<Media> songList = [];
                return RefreshIndicator(
                  onRefresh: () async => await loadContent(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    physics: scrollPhysics,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      if (list[i]['type'] == 'stream') {
                        songList.add(Media.from(list[i]));
                        return SongTile(list: songList, i: songList.length - 1);
                      } else {
                        return PlaylistTile(
                          info: list[i],
                          path: const [0, 1],
                          playlist: true,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
