import 'dart:async';
import 'dart:convert';

import 'package:coil/functions/prefs.dart';
import 'package:coil/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';

import '../data.dart';

void goToPage(Widget page) {
  if (navigatorKey.currentContext == null) return;
  Navigator.of(navigatorKey.currentContext!).push(
    MaterialPageRoute(builder: (c) => page),
  );
}

void showSnack(String text, bool good, {Function()? onTap}) {
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
    SnackBar(
      backgroundColor: good ? Colors.green.shade200 : Colors.red.shade200,
      content: Center(
        child: TextButton(
          onPressed: onTap ?? () {},
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

String formatUrl(String old) {
  old = old.replaceAll('/watch?v=', '');
  return old.replaceAll('/playlist?list=', '');
}

String formatList(String name) {
  if (name.startsWith('Album ')) {
    name = name.replaceRange(0, 8, '');
  }
  return name;
}

Future<String> writeFile(String name, String content) async {
  return await FlutterFileSaver().writeFileAsString(
    fileName: name,
    data: content,
  );
}

Future<String> getInput(String? init, {String? hintText}) async {
  if (navigatorKey.currentContext == null) return '';
  Completer<String> completer = Completer();
  TextEditingController controller = TextEditingController(text: init);
  BuildContext context = navigatorKey.currentContext!;
  showModalBottomSheet(
    context: context,
    barrierColor: Colors.black.withOpacity(0.8),
    builder: (c) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: TextField(
          cursorColor: Colors.white,
          decoration: InputDecoration(
            labelText: hintText,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            floatingLabelAlignment: FloatingLabelAlignment.center,
            labelStyle: const TextStyle(color: Colors.white),
          ),
          autofocus: true,
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ),
          onSubmitted: (text) {
            Navigator.of(c).pop();
            completer.complete(text);
          },
        ),
      );
    },
  );
  return completer.future;
}

void refreshInterface() {
  themeNotifier.value = theme(color(true), color(false));
  refreshPlaylist.value = !refreshPlaylist.value;
}

void rememberSearch(String str) {
  if (str == '') return;
  List<String> list = pf['searchHistory'];
  for (int i = 0; i < 10 && i < list.length; i++) {
    if (list[i] == str) return;
  }
  list.insert(0, str);
  if (list.length > pf['searchHistoryLimit']) {
    list.removeLast();
  }
  setPref('searchHistory', list);
}

void rememberInstance(String str) {
  if (str == '') return;
  str = trimUrl(str.replaceAll(' ', ''));
  List<String> list = pf['instanceHistory'];
  for (int i = 0; i < 10 && i < list.length; i++) {
    if (list[i] == str) return;
  }
  list.insert(0, str);
  if (list.length > pf['searchHistoryLimit']) {
    list.removeLast();
  }
  setPref('instanceHistory', list);
}

Future<int> loadLocale() async {
  final String response = await rootBundle.loadString(
    'assets/translations/${pf['locale']}.json',
  );
  l = await jsonDecode(response);
  return 0;
}

String trimUrl(String raw) {
  return raw.trim().replaceAll('https://', '').replaceAll('/', '');
}

String t(dynamic d) {
  String s = '$d';
  if (s.startsWith('pf//')) {
    return t(pf[s.replaceAll('pf//', '')]);
  }
  return l[s] ?? s;
}
