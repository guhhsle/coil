import 'dart:async';
import 'dart:io';

import 'package:coil/audio/queue.dart';
import 'package:coil/audio/remember.dart';
import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

import '../media/media.dart';
import 'player.dart';

enum LoopMode { off, one, all }

class Handler {
  static final Handler instance = Handler.internal();
  late final SimpleAudio player;
  late IOSink debugOutput = File('debug_output.txt').openWrite();
  LoopMode loop = LoopMode.off;
  List<Media> queuePlaying = [];
  List<Media> queueLoading = [];
  final ValueNotifier<int> current = ValueNotifier(0);
  final ValueNotifier<bool> refreshQueue = ValueNotifier(false);

  factory Handler() {
    return instance;
  }

  Handler.internal() {
    runZoned(
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          debugOutput.writeln(line);
        },
      ),
      () async {
        await SimpleAudio.init(
          useMediaController: true,
          shouldNormalizeVolume: false,
          dbusName: "com.erikas.SimpleAudio",
          actions: [
            MediaControlAction.skipPrev,
            MediaControlAction.playPause,
            MediaControlAction.skipNext,
          ],
          androidNotificationIconPath: "mipmap/ic_launcher",
          androidCompactActions: [1, 2, 3],
          applePreferSkipButtons: true,
        );

        player = SimpleAudio(
          onSkipNext: (_) => skipTo(current.value + 1),
          onSkipPrevious: (_) async {
            if ((await player.progressStateStream.first).position < 10) {
              await skipTo(current.value - 1);
            } else {
              await player.seek(0);
            }
          },
          onNetworkStreamError: (player, error) {
            debugPrint("Network Stream Error: $error");
            player.stop();
          },
          onDecodeError: (player, error) {
            debugPrint("Decode Error: $error");
            player.stop();
          },
        );
        setVolume();
        player.playbackStateStream.listen((event) {
          if (event == PlaybackState.done) {
            skipTo(
              {
                LoopMode.off: current.value + 1,
                LoopMode.one: current.value,
                LoopMode.all: current.value == queuePlaying.length - 1 ? 0 : current.value + 1,
              }[loop]!,
            );
          }
        });
        rememberStream();
      },
    );
  }

  bool tryLoadFromCache(Media media) {
    for (int q = 0; q < queuePlaying.length; q++) {
      if (queuePlaying[q].id == media.id && queuePlaying[q].extras['url'] != '') {
        media.extras['url'] = queuePlaying[q].extras['url'];
        media.extras['audioUrls'] = queuePlaying[q].extras['audioUrls'];
        media.extras['video'] = queuePlaying[q].extras['video'];
        return true;
      }
    }
    for (int q = 0; q < queueLoading.length; q++) {
      if (queueLoading[q].id == media.id && queueLoading[q].extras['url'] != '') {
        media.extras['url'] = queueLoading[q].extras['url'];
        media.extras['audioUrls'] = queueLoading[q].extras['audioUrls'];
        media.extras['video'] = queueLoading[q].extras['video'];
        return true;
      }
    }
    return false;
  }

  bool selected(Media media) {
    if (current.value >= queuePlaying.length) return false;
    return media.id == queuePlaying[current.value].id;
  }
}
