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
      audioUrls = (raw['audioStreams'] as List).map((e) => MediaLink.from(e)).toList()
        ..sort((a, b) => a.bitrate!.compareTo(b.bitrate!));

      videoUrls = (raw['videoStreams'] as List).where((e) => !e['videoOnly']).map((e) => MediaLink.from(e)).toList()
        ..sort((a, b) => b.quality!.compareTo(a.quality!));

      String url = audioUrls[0].url;
      int diff = (pf['bitrate'] - audioUrls[0].bitrate!).abs();
      for (MediaLink link in audioUrls) {
        int currDiff = (pf['bitrate'] - link.bitrate!).abs();
        if (currDiff < diff) {
          url = link.url;
          diff = currDiff;
        }
      }

      audioUrl = url;
    } catch (e) {
      //FORMAT ERROR
    }
    return audioUrl;
  }
}
