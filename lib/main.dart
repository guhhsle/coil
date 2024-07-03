import 'dart:async';
import 'package:coil/audio/handler.dart';
import 'package:coil/threads/main_thread.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'data.dart';
import 'pages/home.dart';
import 'template/app.dart';
import 'template/functions.dart';
import 'template/prefs.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();
  if (pf['appDirectory'] == '' && !kIsWeb) {
    pf['appDirectory'] = (await getApplicationCacheDirectory()).path;
  }
  try {
    MainThread();
  } catch (e) {
    Future.delayed(const Duration(seconds: 1)).then((val) {
      showSnack('Audio unsupported', false);
    });
  }
  MediaHandler();
  runApp(const App(title: 'Coil', child: Home()));
}
