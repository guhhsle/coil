import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:http/http.dart';

import '../data.dart';

Future<void> search(String query, String filter) async {
  Response response = await get(
    Uri.https(
      pf['instance'],
      'search',
      {'q': query, 'filter': filter},
    ),
  );
  List? list = jsonDecode(utf8.decode(response.bodyBytes))['items'];
  if (list != null) searchResults.value = list;
}

Future<void> lyrics(MediaItem item) async {
  currentLyrics.value = '...';
  if (item.extras!['lyrics'] == null) {
    Response response = await get(
      Uri.https(pf['lyricsApi'], 'next/${item.id}'),
    );
    String lyricsId = jsonDecode(response.body)['lyricsId'];
    response = await get(
      Uri.https(pf['lyricsApi'], 'lyrics/$lyricsId'),
    );
    String text = jsonDecode(utf8.decode(response.bodyBytes))['text'] ?? '';
    for (int i = 0; i < text.length; i++) {
      if (text[i] == '\n') {
        String help = text;
        text = '${help.substring(0, i)}\n\n${help.substring(i + 1)}';
        i++;
      }
    }
    String source = jsonDecode(response.body)['source'] ?? '';
    if (text == '') {
      item.extras!['lyrics'] = null;
      currentLyrics.value = '404: Error Not Found';
      return;
    }
    item.extras!['lyrics'] = '$text\n\n\n\n$source';
  }
  currentLyrics.value = item.extras!['lyrics'];
}

Future<void> forceLoad(MediaItem item) async {
  if (item.extras!['url'] == '' && item.extras!['offline'] == null) {
    try {
      for (int q = 0; q < queuePlaying.length; q++) {
        if (queuePlaying[q].id == item.id && queuePlaying[q].extras!['url'] != '') {
          item.extras!['url'] = queuePlaying[q].extras!['url'];
          item.extras!['audioUrls'] = queuePlaying[q].extras!['audioUrls'];
          item.extras!['video'] = queuePlaying[q].extras!['video'];
          return;
        }
      }
      for (int q = 0; q < queueLoading.length; q++) {
        if (queueLoading[q].id == item.id && queueLoading[q].extras!['url'] != '') {
          item.extras!['url'] = queueLoading[q].extras!['url'];
          item.extras!['audioUrls'] = queueLoading[q].extras!['audioUrls'];
          item.extras!['video'] = queueLoading[q].extras!['video'];
          return;
        }
      }
      Response result = await get(
        Uri.https(pf['instance'], 'streams/${item.id}'),
      );
      Map raw = jsonDecode(result.body);
      List audios = raw['audioStreams'];
      Map<String, int> bitrates = {};
      for (int i = 0; i < audios.length; i++) {
        bitrates.addAll({audios[i]['url']: audios[i]['bitrate']});
      }
      Map<String, int> sorted = item.extras!['audioUrls'] = Map.fromEntries(
        bitrates.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)),
      );
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
      item.extras!['url'] = url;
      (item.extras!['video'] as List<Map>).clear();
      for (int i = raw['videoStreams'].length - 1; i >= 0; i--) {
        if (!raw['videoStreams'][i]['videoOnly']) {
          Map video = raw['videoStreams'][i];
          (item.extras!['video'] as List<Map>).add(
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
  }
}
