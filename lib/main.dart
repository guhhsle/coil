import 'dart:async';
import 'package:coil/audio/handler.dart';
import 'package:coil/theme.dart';
import 'package:coil/threads/main_thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'functions/other.dart';
import 'functions/prefs.dart';
import 'pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();
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
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            return MaterialApp(
              locale: Locale(pf['locale']),
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: theme(color(true, lightTheme: true), color(false, lightTheme: true)),
              darkTheme: theme(color(true, lightTheme: false), color(false, lightTheme: false)),
              title: 'Coil',
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
                          const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                        );
                        return const Home();
                      },
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
