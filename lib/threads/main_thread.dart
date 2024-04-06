import 'dart:convert';
import 'dart:isolate';
import 'package:coil/audio/handler.dart';
import 'package:coil/threads/handler_thread.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class MainThread {
  static final MainThread instance = MainThread.internal();
  static final ReceivePort receivePort = ReceivePort('mainFromHandler');

  static late final SendPort sendPort;
  factory MainThread() {
    return instance;
  }

  MainThread.internal() {
    receivePort.listen((message) {
      if (message is SendPort) {
        sendPort = message;
      } else if (message is String) {
        MapEntry entry = jsonDecode(message).entries.first;
        final key = entry.key;
        final value = entry.value;
        if (key == 'Processing') {
          MediaHandler().processing.add(value);
        } else if (key == 'Position') {
          MediaHandler().position.sink.add(value);
        } else if (key == 'Playing') {
          MediaHandler().playing.sink.add(value);
        } else if (key == 'Duration') {
          MediaHandler().duration.sink.add(value);
        }
      }
    });
    //isolateData.token = RootIsolateToken.instance!;
    FlutterIsolate.spawn(handlerThread, receivePort.sendPort);
  }

  static Future<void> callFn(Map map) async {
    sendPort.send(jsonEncode(map));
  }
}
