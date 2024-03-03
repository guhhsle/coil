import 'dart:convert';

import 'package:coil/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'layer.dart';

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();

  for (var i = 0; i < pf.length; i++) {
    String key = pf.keys.elementAt(i);
    if (pf[key] is String) {
      if (prefs.getString(key) == null) {
        prefs.setString(key, pf[key]);
      } else {
        pf[key] = prefs.getString(key)!;
      }
    } else if (pf[key] is int) {
      if (prefs.getInt(key) == null) {
        prefs.setInt(key, pf[key]);
      } else {
        pf[key] = prefs.getInt(key)!;
      }
    } else if (key == 'firstBoot') {
      if (prefs.getBool('firstBoot') == null) {
        prefs.setBool('firstBoot', false);
      } else {
        pf['firstBoot'] = false;
      }
    } else if (pf[key] is bool) {
      if (prefs.getBool(key) == null) {
        prefs.setBool(key, pf[key]);
      } else {
        pf[key] = prefs.getBool(key)!;
      }
    } else if (pf[key] is List<String>) {
      if (prefs.getStringList(key) == null) {
        prefs.setStringList(key, pf[key]);
      } else {
        pf[key] = prefs.getStringList(key)!;
      }
    }
  }
  if (pf['appDirectory'] == '') {
    pf['appDirectory'] = (await getApplicationCacheDirectory()).path;
  }
}

Color color(bool primary) {
  if (primary) {
    return colors[pf['primary']] ?? Color(int.tryParse('0xFF${pf['primary']}') ?? 0xFF170a1c);
  } else {
    return colors[pf['background']] ?? Color(int.tryParse('0xFF${pf['background']}') ?? 0xFFf6f7eb);
  }
}

Color lighterColor(Color p, Color q) {
  if (p.computeLuminance() > q.computeLuminance()) return p;
  return q;
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

void setPref(
  String pString,
  var value, {
  bool refresh = false,
}) {
  pf[pString] = value;
  if (value is int) {
    prefs.setInt(pString, value);
  } else if (value is bool) {
    prefs.setBool(pString, value);
  } else if (value is String) {
    prefs.setString(pString, value);
  } else if (value is List<String>) {
    prefs.setStringList(pString, value);
  }
  if (refresh) refreshInterface();
  if (pString == 'instance' || pString == 'authInstance') {
    rememberInstance(value);
  }
  refreshLayer();
}

ListTile settingToTile(Setting set, BuildContext context) {
  Widget? leading, trailing;
  if (set.secondary == null) {
    leading = Icon(set.icon, color: set.iconColor);
    trailing = Text(t(set.trailing));
  } else {
    trailing = InkWell(
      borderRadius: BorderRadius.circular(10),
      child: Icon(set.icon, color: set.iconColor),
      onTap: () {
        set.secondary!(context);
        refreshLayer();
      },
    );
  }

  return ListTile(
    leading: leading,
    title: Text(t(set.title)),
    trailing: trailing,
    onTap: () {
      set.onTap(context);
      refreshLayer();
    },
    onLongPress: set.onHold == null
        ? null
        : () {
            set.onHold!(context);
            refreshLayer();
          },
  );
}

void refreshInterface() {
  themeNotifier.value = theme(color(true), color(false));
  refreshPlaylist.value = !refreshPlaylist.value;
}

void revPref(
  String pref, {
  bool refresh = false,
}) =>
    setPref(
      pref,
      !pf[pref],
      refresh: refresh,
    );

void nextPref(
  String pref,
  List<String> list, {
  bool refresh = false,
}) {
  setPref(
    pref,
    list[(list.indexOf(pf[pref]) + 1) % list.length],
    refresh: refresh,
  );
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

void checkToRemember(Duration duration, Duration position) {
  if (duration.inMinutes >= pf['rememberThreshold'] && position.inSeconds > 10 && position.inSeconds % 5 == 0) {
    List<String> urls = pf['rememberURLs'] as List<String>;
    if (!urls.contains(queuePlaying[current.value].id)) {
      if (urls.length > pf['rememberLimit']) {
        urls.removeLast();
        pf['rememberTimes'].removeLast;
      }
      urls.insert(0, queuePlaying[current.value].id);
      pf['rememberTimes'].insert(0, '0');
      setPref('rememberURLs', urls);
    } else {
      pf['rememberTimes'][urls.indexOf(queuePlaying[current.value].id)] = '${position.inSeconds}';
    }
    setPref('rememberTimes', pf['rememberTimes']);
  }
}

int rememberedPosition(String url) {
  if (!pf['rememberURLs'].contains(url)) return 0;
  int i = pf['rememberURLs'].indexOf(url);
  return int.tryParse(pf['rememberTimes'][i]) ?? 0;
}
