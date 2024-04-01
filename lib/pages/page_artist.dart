import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../audio/float.dart';
import '../audio/top_icon.dart';
import '../data.dart';
import '../media/media.dart';
import '../widgets/body.dart';
import '../widgets/custom_chip.dart';
import '../widgets/song_tile.dart';
import '../widgets/thumbnail.dart';

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
  Future<bool> subscribed(String channelId) async {
    Response result = await get(
      Uri.https(pf['authInstance'], 'subscribed', {
        'channelId': channelId,
      }),
      headers: {'Authorization': pf['token']},
    );
    return jsonDecode(result.body)['subscribed'];
  }

  Future<void> unSubscribe(String channelId, bool s) async {
    await post(
      Uri.https(pf['authInstance'], s ? 'unsubscribe' : 'subscribe'),
      headers: {
        'Authorization': pf['token'],
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'channelId': channelId}),
    );
  }

  @override
  void initState() {
    unawaited(channelVideos(widget.url));
    super.initState();
  }

  String selectedHome = 'Tabs';

  final ValueNotifier<Map?> videos = ValueNotifier(null);
  final ValueNotifier<Map?> playlists = ValueNotifier(null);

  List<String> options = ['Videos', 'Tabs'];

  Future<void> channelVideos(String url) async {
    try {
      Response result = await get(Uri.https(pf['instance'], url));
      videos.value = jsonDecode(utf8.decode(result.bodyBytes));
      result = await get(
        Uri.https(
          pf['instance'],
          'channels/tabs',
          {'data': (jsonDecode(result.body)['tabs'][0])['data']},
        ),
      );
      playlists.value = jsonDecode(utf8.decode(result.bodyBytes));
    } catch (e) {
      //INVALID CHANNEL
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const Float(),
      appBar: AppBar(
        title: Text(
          widget.artist.replaceAll(' - Topic', '').replaceAll('Album - ', ''),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: TopIcon()),
        ],
      ),
      body: Body(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 64,
              child: ListView.builder(
                physics: scrollPhysics,
                scrollDirection: Axis.horizontal,
                itemCount: options.length + 1,
                itemBuilder: (context, i) {
                  if (i < options.length) {
                    return CustomChip(
                      selected: selectedHome == options[i],
                      onSelected: (val) {
                        selectedHome = options[i];
                        setState(() {});
                      },
                      label: options[i],
                    );
                  } else {
                    return ValueListenableBuilder(
                      valueListenable: videos,
                      builder: (context, data, child) {
                        if (videos.value == null) return Container();
                        return FutureBuilder<bool>(
                          future: subscribed(videos.value!['id']),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            return CustomChip(
                              selected: snapshot.data!,
                              onSelected: (val) async {
                                await unSubscribe(
                                  videos.value!['id'],
                                  snapshot.data!,
                                );
                                setState(() {});
                              },
                              label: 'Subscribe${snapshot.data! ? 'd' : ''} - ${videos.value!['subscriberCount']}',
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: selectedHome == 'Videos' ? videos : playlists,
                builder: (context, data, child) {
                  if (data == null) return Container();
                  List list = selectedHome == 'Videos' ? data['relatedStreams'] : data['content'];
                  List<Media> songList = [];
                  return RefreshIndicator(
                    onRefresh: () async => await channelVideos(widget.url),
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 32, top: 16),
                      physics: scrollPhysics,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            for (Map item in list)
                              Builder(
                                builder: (context) {
                                  if (item['type'] == 'stream') {
                                    songList.add(Media.from(item));
                                    return SongTile(list: songList, i: songList.length - 1);
                                  } else {
                                    return PlaylistTile(
                                      info: item,
                                      path: const [0, 1],
                                      playlist: true,
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
