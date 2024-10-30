import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:flutter/material.dart';
import '../template/functions.dart';
import '../data.dart';

double? calculateShift(BuildContext context, int index, Map map) {
  double tagsLength = Pref.locale.value == 'ja' ? 28 : 22;
  double wantedShift = index == 0 ? 0 : 28;
  double word = Pref.locale.value == 'ja' ? 14 : 8.45;
  double width = MediaQuery.of(context).size.width;
  for (int i = 0; i < map.length; i++) {
    tagsLength += 24 + t(map.keys.elementAt(i)).length * word;
  }
  for (int i = 0; i < index - 1; i++) {
    wantedShift += 24 + t(map.keys.elementAt(i)).length * word;
  }
  double maxShift = 86 + tagsLength - width;

  if (wantedShift < maxShift) {
    return wantedShift;
  } else if (tagsLength > width) {
    return maxShift;
  } else {
    return null;
  }
}

String formatInstanceName(String str) {
  if (!str.contains('.')) return str;
  int i = str.length - 1;
  while (str[i] != '.' && i != 0) {
    i--;
  }
  i--;
  while (str[i] != '.' && i != 0) {
    i--;
  }
  return str.substring(i + 1);
}

String formatUrl(String old) {
  old = old.replaceAll('/watch?v=', '');
  return old.replaceAll('/playlist?list=', '');
}

String formatName(String name) {
  if (name.startsWith('Album ')) {
    name = name.replaceRange(0, 8, '');
  }
  name = name.replaceAll(' - Topic', '');
  return name;
}

Future<String> writeFile(String name, String content) async {
  return await FlutterFileSaver().writeFileAsString(
    fileName: name,
    data: content,
  );
}

void rememberSearch(String str) {
  if (str == '') return;
  List<String> list = Pref.searchHistory.value;
  for (int i = 0; i < 10 && i < list.length; i++) {
    if (list[i] == str) return;
  }
  list.insert(0, str);
  if (list.length > Pref.searchHistoryLimit.value) {
    list.removeLast();
  }
  Pref.searchHistory.set(list);
}

String trimUrl(String raw) {
  return raw
      .trim()
      .replaceAll('https://', '')
      .replaceAll('/', '')
      .replaceAll(' ', '');
}
