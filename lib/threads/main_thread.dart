import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:coil/audio/handler.dart';
import 'package:coil/threads/handler_thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import '../data.dart';
import '../template/functions.dart';

class MainThread {
  static final MainThread instance = MainThread.internal();
  static final ReceivePort receivePort = ReceivePort('mainFromHandler');

  static final Map<String, ValueNotifier> streamMap = {
    'Processing': MediaHandler().processing,
    'Position': MediaHandler().position,
    'Playing': MediaHandler().playing,
    'Duration': MediaHandler().duration,
  };

  static late final SendPort sendPort;
  factory MainThread() {
    return instance;
  }

  MainThread.internal() {
    try {
      receivePort.listen((message) {
        if (message is SendPort) {
          sendPort = message;
          callFn({'volume': pf['volume']});
        } else if (message is String) {
          MapEntry entry = jsonDecode(message).entries.first;
          final key = entry.key;
          final value = entry.value;
          if (key == 'Error') {
            showSnack(value, false);
          } else {
            streamMap[key]?.value = value;
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    //isolateData.token = RootIsolateToken.instance!;
    if (Platform.isAndroid || Platform.isIOS) {
      FlutterIsolate.spawn(handlerThread, receivePort.sendPort);
    } else {
      handlerThread(receivePort.sendPort);
    }
  }

  static Future<void> callFn(Map map) async {
    sendPort.send(jsonEncode(map));
  }
}
