import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'streams.dart';
import 'queue.dart';
import '../threads/main_thread.dart';
import '../media/media_queue.dart';
import '../media/media.dart';

class MediaHandler extends BaseAudioHandler with ChangeNotifier {
  static final MediaHandler instance = MediaHandler.internal();

  final processing = ValueNotifier('idle');
  final duration = ValueNotifier(1000);
  final playing = ValueNotifier(false);
  final position = ValueNotifier(0);

  var bottomText = PageController();
  bool loop = false;
  final tracklist = MediaQueue([]);
  int index = 0;
  //List<Media> queuePlaying = [];
  //static final refreshQueue = ValueNotifier(false);

  factory MediaHandler() => instance;

  MediaHandler.internal() {
    AudioService.init(builder: () => this).then((value) {
      value.initStreams();
    });
  }

  void notify() => notifyListeners();

  @override
  Future<void> skipToNext() async => skipTo(index + 1);

  @override
  Future<void> skipToPrevious() async {
    if (position.value < 5) {
      skipTo(index - 1);
    } else {
      MainThread.callFn({'seek': 0});
    }
  }

  @override
  Future<void> play() => MainThread.callFn({'resume': null});

  @override
  Future<void> pause() => MainThread.callFn({'pause': null});

  @override
  Future<void> stop() async {
    MainThread.callFn({'stop': null});
    tracklist.clear();
    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) => MainThread.callFn({
        'seek': position.inSeconds,
      });

  bool selected(Media media) {
    if (index >= length) return false;
    return media.id == current.id;
  }

  bool get isEmpty => tracklist.isEmpty;

  bool tryLoad(Media media) {
    for (var item in tracklist.list) {
      if (item.id != media.id || item.audioUrl == null) continue;
      media.videoUrls = item.videoUrls;
      media.audioUrls = item.audioUrls;
      media.audioUrl = item.audioUrl;
      return true;
    }
    return false;
  }

  int get length => tracklist.length;
  Media get current => this[index];

  Media operator [](int i) => tracklist[i];
}
