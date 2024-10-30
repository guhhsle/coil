import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'subscriptions.dart';
import '../widgets/playlist_tile.dart';
import '../template/tile_chip.dart';
import '../media/media_queue.dart';
import '../widgets/song_tile.dart';
import '../functions/other.dart';
import '../template/data.dart';
import '../template/tile.dart';
import '../widgets/frame.dart';
import '../media/media.dart';
import '../data.dart';

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

const options = ['Videos', 'Other'];

class PageArtistState extends State<PageArtist> {
  bool isSubscribed = false;
  String selectedHome = 'Videos';
  Map videos = {};
  Map playlists = {};

  Future<void> unSubscribe() async {
    if (Pref.token.value == '') {
      File file = File('${Pref.appDirectory.value}/subscriptions.json');
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
        Uri.https(
          Pref.authInstance.value,
          isSubscribed ? 'unsubscribe' : 'subscribe',
        ),
        headers: {
          'Authorization': Pref.token.value,
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
      Response result = await get(Uri.https(Pref.instance.value, widget.url));
      videos = jsonDecode(utf8.decode(result.bodyBytes));
      setState(() {});
      result = await get(
        Uri.https(
          Pref.instance.value,
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
    loadContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isSubscribed = userSubscriptions.value
            .indexWhere((e) => e['url'].contains(widget.url)) >=
        0;
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
                  TileChip(
                    selected: selectedHome == option,
                    showAvatar: false,
                    tile: Tile(option, Icons.filter_rounded, '', () {
                      selectedHome = option;
                      setState(() {});
                    }),
                  ),
                TileChip(
                  selected: isSubscribed,
                  showCheckmark: true,
                  showAvatar: false,
                  tile: Tile(
                    videos['subscriberCount'],
                    Icons.numbers_rounded,
                    '',
                    unSubscribe,
                  ),
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
                final queue = MediaQueue([]);
                return RefreshIndicator(
                  onRefresh: () async => await loadContent(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    physics: scrollPhysics,
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      if (list[i]['type'] == 'stream') {
                        final media = Media.from(map: list[i], queue: queue);
                        queue.add(media);
                        return SongTile(media: media);
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
