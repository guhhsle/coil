//

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:coil/functions/prefs.dart';
import 'package:coil/media/audio.dart';
import 'package:coil/media/cache.dart';
import 'package:coil/media/http.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
//import 'package:open_as_default/open_as_default.dart';
//import 'package:path/path.dart' as path;

import '../data.dart';
import '../media/media.dart';
import '../widgets/sheet_queue.dart';

enum LoopMode { off, one, all }

final AudioPlayer player = AudioPlayer();
LoopMode loop = LoopMode.off;
final Stream<PlayerState> stateStream = player.playerStateStream;
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
  Future<void> stop() async {
    queuePlaying.clear();
    current.value = 0;
    player.stop();
  }

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

Future<void> preload({int range = 5}) async {
  var futures = <Future>[];
  if (range == 10) {
    for (int i = 0; i < 10; i++) {
      if (i >= 0 && i < queueLoading.length) {
        futures.add(queueLoading[i].forceLoad());
      }
    }
  } else {
    for (int i = current.value - 2; i < current.value + range; i++) {
      if (i >= 0 && i < queuePlaying.length) {
        futures.add(queuePlaying[i].forceLoad());
      }
    }
  }
  await Future.wait(futures);
}

Future<void> removeItemAt(int index) async {
  queuePlaying.removeAt(index);
  unawaited(preload());
  if (index < current.value) current.value = current.value - 1;
  controller.value = PageController(initialPage: current.value);
  refreshQueue.value = !refreshQueue.value;
}

void shuffle() {
  Media media = queuePlaying[current.value];
  queuePlaying.shuffle();
  current.value = queuePlaying.indexOf(media);
  controller.value = PageController(initialPage: current.value);
  refreshQueue.value = !refreshQueue.value;
}

void load(List<Media> list) {
  if (list == queuePlaying) return;
  queuePlaying.clear();
  for (Media media in list) {
    queuePlaying.add(media..extras!['playlist'] = 'queue');
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
  await queuePlaying[i].forceLoad();
  unawaited(queuePlaying[i].play());
  controller.value = PageController(initialPage: i);
  refreshQueue.value = !refreshQueue.value;
}

void setVolume() {
  player.setVolume(pf['volume'] / 100);
}

//
