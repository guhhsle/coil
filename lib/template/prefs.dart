import 'package:coil/template/functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'layer.dart';

Future<void> initPrefs() async {
  prefs = await SharedPreferences.getInstance();

  for (MapEntry entry in pf.entries) {
    final val = getPref(entry.key);
    if (val != null) pf[entry.key] = val;
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

dynamic getPref(pString) {
  if (prefs.get(pString) is List) {
    return prefs.getStringList(pString);
  } else {
    return prefs.get(pString);
  }
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
    await prefs.setStringList(pString, pf[pString]);
  }
  if (refresh) refreshInterface();
  refreshLayer();
  return value;
}