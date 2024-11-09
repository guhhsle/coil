import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'media.dart';
import '../template/functions.dart';
import '../playlist/cache.dart';
import '../audio/handler.dart';
import '../data.dart';

extension MediaHTTP on Media {
  Future<String?> load({bool showError = false}) async {
    if (offline || audioUrl != null) return audioUrl;
    final tryFrom = [...allPlaylists, MediaHandler().tracklist];
    for (final tryQueue in tryFrom) {
      for (final tryMedia in tryQueue.list) {
        if (tryMedia.id == id && tryMedia.audioUrl != null) {
          return copyLoaded(tryMedia);
        }
      }
    }
    return await forceLoad(
      instance: Pref.instance.value,
      showError: showError,
    );
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
      String? newThumbnail = raw['thumbnailUrl'];
      if (newThumbnail != null) {
        thumbnail = newThumbnail;
        backupThumbnail();
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
      return audioUrl = url;
    } catch (e) {
      debugPrint('Error loading song: $e');
      //FORMAT ERROR
    }
    return null;
  }

  Future<void> backupThumbnail() async {
    for (final playlist in allPlaylists) {
      for (final m in playlist.list) {
        if (m.id == id) {
          m.thumbnail = thumbnail;
          await playlist.backup();
        }
      }
    }
  }

  String copyLoaded(Media media) {
    debugPrint('Found already loaded $title');
    videoUrls = media.videoUrls;
    audioUrls = media.audioUrls;
    return audioUrl = media.audioUrl!;
  }
}
