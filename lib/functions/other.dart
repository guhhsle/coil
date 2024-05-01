import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_file_saver/flutter_file_saver.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/prefs.dart';

double? calculateShift(BuildContext context, int index, Map map) {
  double tagsLength = pf['locale'] == 'ja' ? 28 : 22;
  double wantedShift = index == 0 ? 0 : 28;
  double word = pf['locale'] == 'ja' ? 14 : 8.45;
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

void refreshList() {
  refreshPlaylist.value = !refreshPlaylist.value;
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

Future<String> instanceHistory() async {
  Completer<String> completer = Completer();
  List<String> history = pf['instanceHistory'];
  showSheet(
    scroll: true,
    func: (non) async => Layer(
      action: Setting(
        'Instances',
        Icons.domain_rounded,
        '',
        (c) async => await launchUrl(
          Uri.parse('https://github.com/TeamPiped/Piped/wiki/Instances'),
          mode: LaunchMode.externalApplication,
        ),
      ),
      list: [
        for (int i = 0; i < history.length; i++)
          Setting(
            history[i],
            {
                  pf['authInstance']: Icons.lock_rounded,
                  pf['instance']: Icons.domain_rounded,
                }[history[i]] ??
                Icons.remove_rounded,
            '',
            (c) {
              Navigator.of(c).pop();
              completer.complete(history[i]);
            },
            secondary: (c) => setPref(
              'instanceHistory',
              pf['instanceHistory']..removeAt(i),
            ),
          ),
        Setting(
          'New',
          Icons.add_rounded,
          '',
          (c) async {
            String newInstance = await getInput('', hintText: 'Instance link');
            newInstance = trimUrl(newInstance);
            setPref('instanceHistory', pf['instanceHistory']..add(newInstance));
          },
        ),
      ],
    ),
  );

  return completer.future;
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

String trimUrl(String raw) {
  return raw.trim().replaceAll('https://', '').replaceAll('/', '').replaceAll(' ', '');
}
