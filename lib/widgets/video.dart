/*


import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:chewie/chewie.dart';
import 'package:conduit/widgets/custom_card.dart';
import 'package:conduit/widgets/sheet_scroll.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:video_player/video_player.dart';

import '../data.dart';

class Video extends StatefulWidget {
  final MediaItem item;
  const Video({super.key, required this.item});

  @override
  VideoState createState() => VideoState();
}

late ChewieController chewieController;
late VideoPlayerController videoPlayerController;

class VideoState extends State<Video> {
  ValueNotifier<Map<Map<IconData, String>, Map<String, void Function(BuildContext)>>> finalMap = ValueNotifier({});

  Future<void> loadVideo(MediaItem item) async {
    Map<Map<IconData, String>, Map<String, void Function(BuildContext)>> map = {
      {Icons.theaters_rounded: 'Quality'}: {'': (c) {}}
    };
    Response result = await get(Uri.https(pf['instance'], 'streams/${item.id}'));
    Map mapRaw = jsonDecode(result.body);
    int height = mapRaw['videoStreams'][0]['height'];
    int width = mapRaw['videoStreams'][0]['width'];

    for (int i = 0; i < mapRaw['videoStreams'].length; i++) {
      Map video = mapRaw['videoStreams'][i];
      if (!video['videoOnly']) {
        map.addAll({
          {Icons.movie_rounded: '${video['codec']} / ${video['format']}'}: {
            video['videoOnly'].toString(): (c) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  videoPlayerController = VideoPlayerController.network(
                    video['url'],
                  );
                  chewieController = ChewieController(
                      autoPlay: true, aspectRatio: width / height, videoPlayerController: videoPlayerController);
                  return Card(
                    margin: const EdgeInsets.all(8),
                    color: Theme.of(context).colorScheme.background.withOpacity(0.85),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: CustomCard(
                            title: mapRaw['title'],
                            child: const Icon(Icons.movie_rounded),
                            onTap: () {},
                          ),
                        ),
                        Container(
                          height: 320,
                          padding: const EdgeInsets.all(16),
                          child: Chewie(
                            controller: chewieController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }
        });
      }
    }
    finalMap.value = map;
  }

  @override
  void dispose() {
    chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    unawaited(loadVideo(widget.item));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: finalMap,
      builder: (context, snap, child) {
        if (finalMap.value.isEmpty) return const SizedBox(height: 320);
        return SheetScrollModel(map: snap);
      },
    );
  }
}

*/
