import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:just_audio/just_audio.dart';

@pragma('vm:entry-point')
void handlerThread(SendPort answerPort) {
  final ReceivePort receivePort = ReceivePort('handlerFromMain');
  answerPort.send(receivePort.sendPort);
  AudioPlayer player = AudioPlayer();

  void callFn(Map map) => answerPort.send(jsonEncode(map));

  void swap(dynamic non) {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void resume(dynamic non) => player.play();

  void pause(dynamic non) => player.pause();

  void stop(dynamic non) => player.stop();

  void volume(int vol) => player.setVolume(vol / 100);

  void seek(int to) => player.seek(Duration(seconds: to));

  Future<void> play(dynamic song) async {
    if (song['offline']) {
      await player.setAudioSource(AudioSource.file(song['url']));
    } else {
      await player.setAudioSource(AudioSource.uri(Uri.parse(song['url'])));
    }
    await player.play();
  }

  final Map<String, Function> funcMap = {
    'play': play,
    'swap': swap,
    'seek': seek,
    'resume': resume,
    'pause': pause,
    'stop': stop,
    'volume': volume,
  };

  player.durationStream.listen((event) {
    if (event == null) return;
    callFn({'Duration': event.inSeconds});
  });

  player.playingStream.listen((e) => callFn({'Playing': e}));

  player.positionStream.listen((e) => callFn({'Position': e.inSeconds}));

  player.processingStateStream.listen((e) => callFn({'Processing': e.name}));

  receivePort.listen((message) {
    if (message is String) {
      MapEntry entry = jsonDecode(message).entries.first;
      try {
        funcMap[entry.key]?.call(entry.value);
      } catch (e) {
        callFn({'Error': '$e'});
      }
    }
  });
}
