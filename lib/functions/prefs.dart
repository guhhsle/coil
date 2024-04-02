import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data.dart';
import '../layer.dart';
import 'other.dart';

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();

  for (MapEntry entry in pf.entries) {
    if (await setPref(entry.key, prefs.get(entry.key)) == null) {
      await setPref(entry.key, entry.value);
    }
  }
  if (pf['appDirectory'] == '') {
    pf['appDirectory'] = (await getApplicationCacheDirectory()).path;
  }
}

Future<void> revPref(String pref, {bool refresh = false}) async {
  await setPref(pref, !pf[pref], refresh: refresh);
}

Future<void> nextPref(String pref, List<String> list, {bool refresh = false}) async {
  await setPref(pref, list[(list.indexOf(pf[pref]) + 1) % list.length], refresh: refresh);
}

Future setPref(String pString, var value, {bool refresh = false}) async {
  pf[pString] = value;
  if (value is int) {
    await prefs.setInt(pString, value);
  } else if (value is bool) {
    await prefs.setBool(pString, value);
  } else if (value is String) {
    await prefs.setString(pString, value);
  } else if (value is List<String>) {
    await prefs.setStringList(pString, value);
  }
  if (refresh) refreshInterface();
  refreshLayer();
  return value;
}
