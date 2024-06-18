import 'dart:async';
import 'package:coil/audio/handler.dart';
import 'package:coil/threads/main_thread.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'data.dart';
import 'pages/home.dart';
import 'template/data.dart';
import 'template/functions.dart';
import 'template/prefs.dart';
import 'template/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();
  if (pf['appDirectory'] == '') {
    pf['appDirectory'] = (await getApplicationCacheDirectory()).path;
  }
  MainThread();
  MediaHandler();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, data, widget) {
        return FutureBuilder(
          future: loadLocale(),
          builder: (context, snapshot) => MaterialApp(
            locale: Locale(pf['locale']),
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: theme(
              color(true, lightTheme: true),
              color(false, lightTheme: true),
            ),
            darkTheme: theme(
              color(true, lightTheme: false),
              color(false, lightTheme: false),
            ),
            title: 'Coil',
            builder: FlashyFlushbarProvider.init(),
            home: Builder(
              builder: (context) {
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: pf['player'] != 'Dock'
                        ? color(false)
                        : {
                            'Black': Colors.black,
                            'Primary': color(true),
                            'Transparent': color(false),
                          }[pf['appbar']],
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                  child: Builder(
                    builder: (context) {
                      SystemChrome.setSystemUIOverlayStyle(
                        const SystemUiOverlayStyle(
                            statusBarColor: Colors.transparent),
                      );
                      return const Home();
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
