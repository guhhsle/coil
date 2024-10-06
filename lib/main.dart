import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'threads/main_thread.dart';
import 'template/functions.dart';
import 'template/prefs.dart';
import 'audio/handler.dart';
import 'template/app.dart';
import 'pages/home.dart';
import 'data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences().init();
  if (Pref.appDirectory.value == '' && !kIsWeb) {
    Pref.appDirectory.set((await getApplicationCacheDirectory()).path);
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
