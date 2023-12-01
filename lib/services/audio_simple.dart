/*
import 'dart:async';

import 'package:audio_service/audio_service.dart' as s;
import 'package:http/http.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets/sheet_queue.dart';
import 'playlist.dart';
import 'song.dart';

enum LoopMode { off, one, all }

Metadata mediaToMeta(s.MediaItem item) {
  return Metadata(
    title: item.title,
    album: item.album ?? '',
    artist: item.artist ?? '',
    artUri: item.artUri.toString(),
  );
}

//late AudioHandler handler;
LoopMode loop = LoopMode.off;
Stream stateStream = player.playbackStateStream;
Duration duration = const Duration(hours: 1);

late final SimpleAudio player;

Future<void> initAudio() async {
  player = SimpleAudio(
    onSkipNext: (_) => debugPrint("Next"),
    onSkipPrevious: (audio) {
      /*
    Duration? dur = await player.getCurrentPosition();
    if ((dur ?? Duration.zero).inSeconds < 10) {
      await skipTo(current.value - 1);
    } else {
      await player.seek(Duration.zero);
    }
		*/
    },
    onNetworkStreamError: (player) {
      debugPrint("Network Stream Error");
      player.stop();
    },
    onDecodeError: (player) {
      debugPrint("Decode Error");
      player.stop();
    },
  );
  await SimpleAudio.init(
    useMediaController: true,
    shouldNormalizeVolume: false,
    dbusName: "com.erikas.SimpleAudio",
    actions: [
      MediaControlAction.rewind,
      MediaControlAction.skipPrev,
      MediaControlAction.playPause,
      MediaControlAction.skipNext,
      MediaControlAction.fastForward
    ],
    androidNotificationIconPath: "mipmap/ic_launcher",
    androidCompactActions: [1, 2, 3],
    applePreferSkipButtons: true,
  );
  player.setVolume(pf['volume'] / 100);
  player.progressStateStream.listen((position) async {
    int raz = position.duration - position.position;
    if (raz == 0) {
      skipTo(
        {
          LoopMode.off: current.value + 1,
          LoopMode.one: current.value,
          LoopMode.all: current.value == queuePlaying.length - 1 ? 0 : current.value + 1,
        }[loop]!,
      );
    }
  });
}

Future<void> skipToNext() async {
  skipTo(current.value + 1);
}

Future<void> skipToPrevious() async {
  skipTo(current.value - 1);
}

Future<void> play() => player.play();
Future<void> pause() => player.pause();
Future<void> stopPlayer() async {
  queuePlaying.clear();
  current.value = 0;
  player.stop();
}

Future<void> addItemToQueue(s.MediaItem mediaItem) async {
  queuePlaying.add(mediaItem);
  unawaited(preload());
  if (queuePlaying.length == 1) skipTo(0);
  controller.value = PageController(initialPage: current.value);
  refreshPlaylist.value = !refreshPlaylist.value;
}

Future<void> insertItemToQueue(
  int index,
  s.MediaItem mediaItem, {
  bool e = false,
}) async {
  if (queuePlaying.isEmpty) {
    addItemToQueue(mediaItem);
    return;
  }
  queuePlaying.insert(index, mediaItem);
  unawaited(preload());
  if (e) {
    current.value = current.value - 1;
  } else if (index <= current.value) {
    current.value = current.value + 1;
  }
  controller.value = PageController(initialPage: current.value);
  refreshQueue.value = !refreshQueue.value;
}

Future<void> removeItemAt(int index) async {
  queuePlaying.removeAt(index);
  unawaited(preload());
  if (index < current.value) current.value = current.value - 1;
  controller.value = PageController(initialPage: current.value);
  refreshQueue.value = !refreshQueue.value;
}


void shuffle() {
  s.MediaItem item = queuePlaying[current.value];
  queuePlaying.shuffle();
  current.value = queuePlaying.indexOf(item);
  controller.value = PageController(initialPage: current.value);
  refreshPlaylist.value = !refreshPlaylist.value;
}

Future<void> playItem(s.MediaItem item) async {
  await player.setMetadata(mediaToMeta(item));
  await player.stop();
  //player.open(item.extras!['url']);
  duration = Duration(seconds: item.extras!['duration'] ?? 999);
  unawaited(preload());
  /*
		simple_audio/rust/src/audio/sources/http.rs
        let header = res
            .headers()
            .get("Content-Length")
            .context("Could not get \"Content-Length\" header for HTTP stream.")?;
		 */
}

void load(List<s.MediaItem> list) {
  queuePlaying = list.toList();
}

Future<void> skipTo(int i) async {
  if (i < 0 || i >= queuePlaying.length) return;
  await forceLoad(queuePlaying[i]);
  await playItem(queuePlaying[i]);
  current.value = i;
  controller.value = PageController(initialPage: i);
  refreshPlaylist.value = !refreshPlaylist.value;
}

void setVolume() {
  player.setVolume(pf['volume'] / 100);
}

class Float extends StatefulWidget {
  const Float({super.key});

  @override
  FloatState createState() => FloatState();
}

class FloatState extends State<Float> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: current,
      builder: (context, snapIndex, widget) {
        return StreamBuilder(
          stream: stateStream,
          builder: (context, snapshot) {
            return StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 300)),
              builder: (context, snap) {
                bool playing = snapshot.hasData && snapshot.data! == PlaybackState.play;
                if (pf['player'] == 'Floating') {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: InkWell(
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return const SheetQueue();
                            },
                          );
                        },
                        onTap: () {
                          if (playing) {
                            pause();
                          } else {
                            play();
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: (queuePlaying.isEmpty)
                            ? Container()
                            : Card(
                                margin: EdgeInsets.zero,
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: pf['songThumbnails'] && queuePlaying[snapIndex].extras!['offline'] == null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            queuePlaying[snapIndex].artUri.toString(),
                                            fit: BoxFit.cover,
                                            height: 24,
                                            width: 24,
                                          ),
                                        )
                                      : Container(
                                          height: 24,
                                          width: 24,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                ),
                              ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }
}

class TopIcon extends StatelessWidget {
  final bool top;
  const TopIcon({super.key, this.top = true});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: current,
      builder: (context, snapIndex, widget) {
        return StreamBuilder(
          stream: stateStream,
          builder: (context, snapshot) {
            return StreamBuilder(
              stream: Stream.periodic(const Duration(milliseconds: 300)),
              builder: (contextm, snap) {
                bool playing = snapshot.hasData && snapshot.data! == PlaybackState.play;
                if (!top || (pf['player'] == 'Top' && queuePlaying.isNotEmpty)) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const SheetQueue();
                        },
                      );
                    },
                    onTap: () {
                      if (playing) {
                        pause();
                      } else {
                        play();
                      }
                    },
                    child: Padding(
                      padding: !top ? const EdgeInsets.only(right: 20) : const EdgeInsets.all(8.0),
                      child: Icon(
                        playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }
}

class AudioSlider extends StatelessWidget {
  const AudioSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stateStream,
      builder: (context, snapshot) {
        return SizedBox(
          height: 24,
          child: StreamBuilder<ProgressState>(
            stream: player.progressStateStream,
            builder: (context, position) {
              if (!position.hasData) return Container();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 84,
                    child: Slider(
                      thumbColor: Theme.of(context).colorScheme.primary,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.primary,
                      secondaryActiveColor: Theme.of(context).colorScheme.primary,
                      value: position.data!.position.toDouble(),
                      min: 0,
                      onChangeEnd: (doub) {
                        player.seek(doub.toInt());
                      },
                      onChanged: (doub) {},
                      max: position.data!.duration.toDouble(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Text(
                      '${position.data!.position / 60}:${position.data!.position % 60}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
*/
