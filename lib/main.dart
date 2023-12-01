import 'dart:async';
import 'package:coil/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'services/audio.dart';
import 'functions.dart';
import 'pages/home.dart';
import 'pages/page_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();
  unawaited(initAudio());
  runApp(MyApp(account: pf['firstBoot']));
}

class MyApp extends StatelessWidget {
  final bool account;
  const MyApp({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: themeNotifier,
      builder: (context, data, widget) {
        return FutureBuilder(
          future: loadLocale(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return MaterialApp(
              locale: Locale(pf['locale']),
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: theme(color(true), color(false)),
              title: 'Coil',
              home: AnnotatedRegion<SystemUiOverlayStyle>(
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
                      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                    );
                    return account ? const PageLog() : const Home();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
