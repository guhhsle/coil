import 'dart:convert';
import 'package:http/http.dart';
import '../data.dart';
import '../media/media.dart';
import '../playlist/playlist.dart';

Map<int, List<Media>> generated = {};
Future<List<Media>> generate(List message) async {
  List<Media> rawList = message[0];
  pf['instance'] = message[1];
  pf['indie'] = message[2];
  List<Media> list = rawList.toList()..shuffle();
  generated.clear();
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
        Media media = generated[key]!.removeAt(j);
        int n = media.quality + 2 * media.reps + media.index ~/ 2;
        if (!generated.containsKey(n)) {
          generated.addAll({
            n: [media]
          });
        } else {
          generated[n]!.add(media);
        }
      }
    }
  }

  Map<int, List<Media>> sorted = Map.fromEntries(
    generated.entries.toList()..sort((e1, e2) => e2.key.compareTo(e1.key)),
  );

  List<Media> finalList = [];
  for (int i = 0; i < sorted.length; i++) {
    finalList += sorted.values.elementAt(i)..shuffle();
  }
  generated.clear();
  return finalList;
}

Future<void> generateFromId(String id) async {
  Response response = await get(Uri.https(pf['instance'], 'streams/$id'));
  late List related;
  try {
    related = jsonDecode(utf8.decode(response.bodyBytes))['relatedStreams'];
  } catch (e) {
    related = jsonDecode(response.body)['relatedStreams'];
  }
  await generateFrom(related, false);
}

Future<void> generateFrom(List related, bool r) async {
  try {
    List<Future> waiting = [];
    for (int i = 0; i < related.length; i++) {
      if (related[i]['type'] == 'playlist') {
        waiting.add(Playlist.load(related[i]['url'], [0, 1]).then((value) {
          generateFrom(value.raw['relatedStreams'], true);
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
    Media media = Media.from(m, i: i < 10 ? 10 - i : 0);
    int e = media.quality;
    if (i == -10) {
      for (int j = generated.length - 1; j >= 0; j--) {
        List<Media> list = generated.values.elementAt(j);
        for (int q = 0; q < list.length; q++) {
          if (media.title == list[q].title) {
            list[q].quality += 10;
            list[q].reps++;
            return;
          }
        }
      }
    }
    if (!generated.containsKey(e)) {
      generated.addAll({
        e: [media]
      });
    } else {
      int j = generated[e]!.indexWhere((el) => el.id == media.id);
      if (j == -1) {
        generated[e]!.add(media);
      } else {
        generated[e]![j].index += 2;
        generated[e]![j].reps++;
      }
    }
  } catch (e) {
    //STRING FORMATTING ERROR
  }
}
