import 'dart:convert';
import 'package:http/http.dart';
import '../audio/handler.dart';
import '../data.dart';
import 'media.dart';

extension Preload on List<Media> {
  Future<void> preload(int from, int to) async {
    var futures = <Future>[];
    for (int i = from; i < to; i++) {
      if (i >= 0 && i < length) {
        futures.add(this[i].forceLoad());
      }
    }
    await Future.wait(futures);
  }
}

extension MediaHTTP on Media {
  Future<String?> forceLoad() async {
    if (offline || audioUrl != null) return audioUrl;
    try {
      if (MediaHandler().tryLoad(this)) return audioUrl!;
      Response result = await get(Uri.https(pf['instance'], 'streams/$id'));
      Map raw = jsonDecode(result.body);
      List audios = raw['audioStreams'];

      Map<String, int> bitrates = {};
      for (int i = 0; i < audios.length; i++) {
        bitrates.addAll({audios[i]['url']: audios[i]['bitrate']});
      }
      Map<String, int> sorted = Map.fromEntries(
        bitrates.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)),
      );
      audioUrls = sorted;
      String url = sorted.keys.first;
      int diff = ((pf['bitrate'] as int) - sorted.values.first).abs();
      if (pf['bitrate'] == 180000) {
        url = sorted.keys.last;
      } else if (pf['bitrate'] != 30000) {
        for (int i = 1; i < sorted.length; i++) {
          if (((pf['bitrate'] as int) - sorted.values.elementAt(i)).abs() < diff) {
            url = sorted.keys.elementAt(i);
            diff = ((pf['bitrate'] as int) - sorted.values.elementAt(i)).abs();
          }
        }
      }
      audioUrl = url;
      videoUrls = [];
      for (int i = raw['videoStreams'].length - 1; i >= 0; i--) {
        if (!raw['videoStreams'][i]['videoOnly']) {
          Map video = raw['videoStreams'][i];
          videoUrls.add(
            {
              'url': video['url'],
              'format': video['format'],
              'quality': video['quality'],
            },
          );
        }
      }
    } catch (e) {
      //FORMAT ERROR
    }
    return audioUrl;
  }
}
