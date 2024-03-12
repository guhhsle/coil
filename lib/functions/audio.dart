//

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:coil/functions/prefs.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
//import 'package:open_as_default/open_as_default.dart';
//import 'package:path/path.dart' as path;

import '../data.dart';
import '../http/other.dart';
import '../http/playlist.dart';
import '../widgets/sheet_queue.dart';
import 'cache.dart';

enum LoopMode { off, one, all }

final AudioPlayer player = AudioPlayer();
LoopMode loop = LoopMode.off;
final Stream stateStream = player.playerStateStream;
late final AudioHandler handler;

Future<void> initAudio() async {
  player.setVolume(pf['volume'] / 100);
  handler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.marko.coil.channel.audio',
      androidNotificationChannelName: 'Music playback',
    ),
  );
}

Duration currentDuration = Duration.zero;

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    player.createPositionStream().listen((position) {
      checkToRemember(currentDuration, position);
      int raz = ((player.duration ?? Duration.zero) - position).inMilliseconds;
      if (raz < 1000 && raz > 0) {
        skipTo(
          {
            LoopMode.off: current.value + 1,
            LoopMode.one: current.value,
            LoopMode.all: current.value == queuePlaying.length - 1 ? 0 : current.value + 1,
          }[loop]!,
        );
      }
    });
    /*
    OpenAsDefault.getFileIntent.then((value) {
      if (value != null) {
        load([
          MediaItem(
            title: path.basename(value.path).replaceAll('.m4a', '').replaceAll('.mp3', ''),
            artist: '',
            id: value.path,
            extras: {'url': value.path, 'offline': true},
          )
        ]);
        skipTo(0);
      }
    });
	*/
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await player.setAudioSource(ConcatenatingAudioSource(children: []));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    player.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> skipToNext() => skipTo(current.value + 1);

  @override
  Future<void> skipToPrevious() async {
    if (player.position.inSeconds < 10) {
      await skipTo(current.value - 1);
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() => stopPlayer();

  @override
  Future<void> addQueueItem(MediaItem mediaItem) => addItemToQueue(mediaItem);

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) {
    return insertItemToQueue(index, mediaItem);
  }

  @override
  Future<void> removeQueueItemAt(int index) => removeItemAt(index);

  @override
  Future<void> seek(Duration position) => player.seek(position);

  void _listenForDurationChanges() {
    player.durationStream.listen((duration) {
      currentDuration = duration ?? Duration.zero;
      var index = player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (player.shuffleModeEnabled) {
        index = player.shuffleIndices!.indexOf(index);
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (player.shuffleModeEnabled) {
        index = player.shuffleIndices!.indexOf(index);
      }
      mediaItem.add(playlist[index]);
      controller.value = PageController(initialPage: index);
    });
  }

  void _listenForSequenceStateChanges() {
    player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }
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

Future<void> addItemToQueue(MediaItem mediaItem) async {
  queuePlaying.add(mediaItem);
  unawaited(preload());
  if (queuePlaying.length == 1) skipTo(0);
  controller.value = PageController(initialPage: current.value);
  refreshQueue.value = !refreshQueue.value;
}

Future<void> insertItemToQueue(
  int index,
  MediaItem mediaItem, {
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
  MediaItem item = queuePlaying[current.value];
  queuePlaying.shuffle();
  current.value = queuePlaying.indexOf(item);
  controller.value = PageController(initialPage: current.value);
  refreshQueue.value = !refreshQueue.value;
}

Future<void> playItem(MediaItem item) async {
  if (item.extras!['offline'] == null) {
    unawaited(addTo100(item));
    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(item.extras!['url']),
        tag: item,
      ),
    );
  } else {
    await player.setAudioSource(
      AudioSource.file(
        item.extras!['url'],
        tag: item,
      ),
    );
  }
  int pos = rememberedPosition(item.id);
  if (pos > 10) await player.seek(Duration(seconds: pos));
  unawaited(player.play());
  unawaited(preload());
}

void load(List<MediaItem> list) {
  if (list == queuePlaying) return;
  queuePlaying.clear();
  for (MediaItem item in list) {
    queuePlaying.add(item..extras!['playlist'] = 'queue');
  }
}

void checkToRemember(Duration duration, Duration position) {
  if (duration.inMinutes >= pf['rememberThreshold'] && position.inSeconds > 10 && position.inSeconds % 5 == 0) {
    List<String> urls = pf['rememberURLs'] as List<String>;
    if (!urls.contains(queuePlaying[current.value].id)) {
      if (urls.length > pf['rememberLimit']) {
        urls.removeLast();
        pf['rememberTimes'].removeLast;
      }
      urls.insert(0, queuePlaying[current.value].id);
      pf['rememberTimes'].insert(0, '0');
      setPref('rememberURLs', urls);
    } else {
      pf['rememberTimes'][urls.indexOf(queuePlaying[current.value].id)] = '${position.inSeconds}';
    }
    setPref('rememberTimes', pf['rememberTimes']);
  }
}

int rememberedPosition(String url) {
  if (!pf['rememberURLs'].contains(url)) return 0;
  int i = pf['rememberURLs'].indexOf(url);
  return int.tryParse(pf['rememberTimes'][i]) ?? 0;
}

Future<void> skipTo(int i) async {
  if (i < 0 || i >= queuePlaying.length) return;
  current.value = i;
  refreshQueue.value = !refreshQueue.value;
  await forceLoad(queuePlaying[i]);
  unawaited(playItem(queuePlaying[i]));
  controller.value = PageController(initialPage: i);
  refreshQueue.value = !refreshQueue.value;
}

void setVolume() {
  player.setVolume(pf['volume'] / 100);
}

class AudioSlider extends StatelessWidget {
  const AudioSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, position) {
        if (!position.hasData) return Container();
        Duration max = player.duration ?? const Duration(hours: 1);
        //Duration pos = position.data!;
        return SizedBox(
          height: 24,
          child: Slider(
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary,
            secondaryActiveColor: Theme.of(context).colorScheme.primary,
            value: position.data!.inSeconds.toDouble(),
            min: 0,
            onChanged: (d) => player.seek(
              Duration(seconds: d.toInt()),
            ),
            max: max.inSeconds.toDouble(),
          ),
        );
        /*
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
                value: position.data!.inSeconds.toDouble(),
                min: 0,
                onChanged: (d) => player.seek(
                  Duration(seconds: d.toInt()),
                ),
                max: max.inSeconds.toDouble(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Text(
                '${pos.inMinutes}:${pos.inSeconds % 60}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
		*/
      },
    );
  }
}

class Float extends StatefulWidget {
  const Float({super.key});

  @override
  FloatState createState() => FloatState();
}

class FloatState extends State<Float> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, snapIndex, widget) {
        return ValueListenableBuilder<int>(
          valueListenable: current,
          builder: (context, snapIndex, widget) {
            return StreamBuilder<Object>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
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
                            builder: (context) => const SheetQueue(),
                          );
                        },
                        onTap: () => player.playing ? pause() : play(),
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
  final Color? color;
  const TopIcon({super.key, this.top = true, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, snapIndex, widget) {
        return ValueListenableBuilder<int>(
          valueListenable: current,
          builder: (context, snapIndex, widget) {
            return StreamBuilder(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                if (top && queuePlaying.isNotEmpty && pf['player'] == 'Top dock') {
                  return ValueListenableBuilder(
                    valueListenable: showTopDock,
                    builder: (context, data, ch) {
                      return IconButton(
                        icon: Icon(data ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                        onPressed: () => showTopDock.value = !showTopDock.value,
                      );
                    },
                  );
                } else if (!top || (pf['player'] == 'Top' && queuePlaying.isNotEmpty)) {
                  ProcessingState? state = snapshot.data?.processingState;
                  return GestureDetector(
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const SheetQueue(),
                    ),
                    child: IconButton(
                      onPressed: () => player.playing ? pause() : play(),
                      icon: Icon(
                        !snapshot.hasData
                            ? Icons.stop_rounded
                            : (state == ProcessingState.buffering || state == ProcessingState.loading)
                                ? Icons.language_rounded
                                : snapshot.data!.playing
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                        color: color ?? Theme.of(context).appBarTheme.foregroundColor,
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

//
