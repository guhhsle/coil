import 'dart:async';
import 'dart:io';

import 'package:coil/audio/queue.dart';
import 'package:coil/audio/remember.dart';
import 'package:coil/functions/other.dart';
import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

import '../media/media.dart';
import 'player.dart';

enum LoopMode { off, one, all }

class Handler {
  static final Handler instance = Handler.internal();
  late SimpleAudio player;
  late IOSink debugOutput = File('debug_output.txt').openWrite();
  LoopMode loop = LoopMode.off;
  List<Media> queuePlaying = [];
  List<Media> queueLoading = [];
  final ValueNotifier<int> current = ValueNotifier(0);
  final ValueNotifier<bool> refreshQueue = ValueNotifier(false);

  factory Handler() {
    return instance;
  }

  Future<void> initHandler() async {
    runZoned(
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => debugOutput.writeln(line),
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
          onNetworkStreamError: (_, error) async {
            showSnack('Instance error for this specific song', false);
            await player.stop();
            await initHandler();
          },
          onDecodeError: (_, error) async {
            showSnack("Decode Error: $error", false);
            await player.stop();
            await initHandler();
          },
        );
        setVolume();
        player.playbackStateStream.listen((event) {
          if (event == PlaybackState.done) {
            bool isLast = current.value == queuePlaying.length - 1;
            skipTo(
              {
                LoopMode.off: current.value + 1,
                LoopMode.one: current.value,
                LoopMode.all: isLast ? 0 : current.value + 1,
              }[loop]!,
            );
          }
        });
        rememberStream();
      },
    );
  }

  Handler.internal() {
    unawaited(initHandler());
  }

  bool tryLoadFromCache(Media media) {
    for (int q = 0; q < queuePlaying.length; q++) {
      if (queuePlaying[q].id == media.id && queuePlaying[q].audioUrl != null) {
        media.audioUrl = queuePlaying[q].audioUrl;
        media.audioUrls = queuePlaying[q].audioUrls;
        media.videoUrls = queuePlaying[q].videoUrls;
        return true;
      }
    }
    for (int q = 0; q < queueLoading.length; q++) {
      if (queueLoading[q].id == media.id && queueLoading[q].audioUrl != null) {
        media.audioUrl = queueLoading[q].audioUrl;
        media.audioUrls = queueLoading[q].audioUrls;
        media.videoUrls = queueLoading[q].videoUrls;
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
