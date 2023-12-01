import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:coil/services/playlist.dart';
import 'package:coil/services/song.dart';
import 'package:http/http.dart';

import '../data.dart';
import '../playlist.dart';

Map<int, List<MediaItem>> generated = {};
Future<bool> generate(List<MediaItem> list) async {
  generated.clear();
  list.shuffle();
  var futures = <Future>[];

  for (int i = 0; i < list.length && i < pf['requestLimit']; i++) {
    futures.add(generateFromId(list[i].id));
  }
  try {
    await Future.wait(futures).timeout(Duration(seconds: pf['timeLimit']));
  } catch (e) {
    //ASYNCHRONOUS FUNCTION TIMED OUT
  }

  if (!pf['indie']) {
    for (int i = 0; i < generated.length; i++) {
      int key = generated.keys.elementAt(i);
      for (int j = 0; j < generated[key]!.length; j++) {
        MediaItem item = generated[key]!.removeAt(j);
        int n = item.extras!['verified'] + 2 * item.extras!['reps'] + item.extras!['index'] ~/ 2;
        if (!generated.containsKey(n)) {
          generated.addAll({
            n: [item]
          });
        } else {
          generated[n]!.add(item);
        }
      }
    }
  }

  Map<int, List<MediaItem>> sorted = Map.fromEntries(
    generated.entries.toList()..sort((e1, e2) => e2.key.compareTo(e1.key)),
  );

  queuePlaying.clear();
  for (int i = 0; i < sorted.length; i++) {
    queuePlaying += sorted.values.elementAt(i)..shuffle();
  }
  generated.clear();
  return false;
}

Future<void> generateFromId(String id) async {
  Response result = await get(Uri.https(pf['instance'], 'streams/$id'));
  await generateFrom(Playlist.fromJson(jsonDecode(utf8.decode(result.bodyBytes)), id), false);
}

Future<void> generateFrom(Playlist m, bool r) async {
  try {
    List related = m.raw['relatedStreams'];
    List<Future> waiting = [];
    for (int i = 0; i < related.length; i++) {
      if (related[i]['type'] == 'playlist') {
        waiting.add(loadPlaylist(related[i]['url'], [0, 1]).then((value) {
          generateFrom(value, true);
        }));
      } else {
        addToGen(related[i], r ? -10 : i);
      }
    }
    await Future.wait(waiting);
  } catch (e) {
    //
  }
}

void addToGen(Map m, int i) {
  try {
    MediaItem item = mapToMedia(m, i: i);
    int e = item.extras!['verified'];
    if (i == -10) {
      for (int j = generated.length - 1; j >= 0; j--) {
        List<MediaItem> list = generated.values.elementAt(j);
        for (int q = 0; q < list.length; q++) {
          if (item.title == list[q].title) {
            list[q].extras!['index'] += 10;
            list[q].extras!['reps']++;
            return;
          }
        }
      }
    }
    if (!generated.containsKey(e)) {
      generated.addAll({
        e: [item]
      });
    } else {
      int j = generated[e]!.indexWhere((el) => el.id == item.id);
      if (j == -1) {
        generated[e]!.add(item);
      } else {
        generated[e]![j].extras!['index'] += 2;
        generated[e]![j].extras!['reps']++;
      }
    }
  } catch (e) {
    //STRING FORMATTING ERROR
  }
}
