import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'media.dart';
import '../template/functions.dart';
import '../audio/handler.dart';
import '../data.dart';

extension Preload on List<Media> {
  Future<void> preload(int from, int to) async {
    var futures = <Future>[];
    for (int i = from; i < to; i++) {
      if (i >= 0 && i < length) {
        futures.add(this[i].load());
      }
    }
    await Future.wait(futures);
  }
}

extension MediaHTTP on Media {
  Future<String?> load({
    bool showError = false,
  }) async {
    if (offline || audioUrl != null) return audioUrl;
    if (MediaHandler().tryLoad(this)) return audioUrl!;
    return forceLoad(instance: Pref.instance.value);
  }

  Future<String?> forceLoad({
    bool showError = false,
    required String instance,
  }) async {
    try {
      Response result = await get(Uri.https(instance, 'streams/$id'));
      Map raw = jsonDecode(result.body);
      if (raw['message'] != null) {
        debugPrint(raw['message']);
        if (showError) showSnack('Instance: ${raw['message']}', false);
      }
      audioUrls = (raw['audioStreams'] as List)
          .map((e) => MediaLink.from(e))
          .toList()
        ..sort((a, b) => a.bitrate!.compareTo(b.bitrate!));

      try {
        videoUrls = (raw['videoStreams'] as List)
            .where((e) => !e['videoOnly'])
            .map((e) => MediaLink.from(e))
            .toList()
          ..sort((a, b) => b.quality!.compareTo(a.quality!));
      } catch (e) {
        debugPrint('Error fetching videos: $e');
      }

      String url = audioUrls[0].url;
      int diff = (Pref.bitrate.value - audioUrls[0].bitrate!).abs();
      for (MediaLink link in audioUrls) {
        int currDiff = (Pref.bitrate.value - link.bitrate!).abs();
        if (currDiff < diff) {
          url = link.url;
          diff = currDiff;
        }
      }
      return url;
    } catch (e) {
      debugPrint('Error loading song: $e');
      //FORMAT ERROR
    }
    return null;
  }
}
