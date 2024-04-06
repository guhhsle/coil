import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import 'map.dart';

class Media extends MediaItem {
  int quality, index, reps;
  bool offline;
  String? audioUrl, playlist, uploaderUrl, lyrics;
  Map<String, int> audioUrls;
  List<Map> videoUrls;

  Media({
    required super.id,
    this.quality = 10,
    this.index = 0,
    this.playlist,
    this.audioUrl,
    this.uploaderUrl,
    this.audioUrls = const {},
    this.lyrics,
    this.videoUrls = const [],
    this.offline = false,
    this.reps = 1,
    required super.title,
    super.duration,
    super.artUri,
    super.artist = '',
  });

  static Media from(Map json, {int? i, String? playlist}) {
    return MediaMap.fromMap(json, i: i ?? 10, playlist: playlist);
  }

  Widget? image({EdgeInsets? padding, force = false}) {
    if (!force) {
      if (!pf['thumbnails']) return null;
      if (offline) return null;
    }
    padding ??= const EdgeInsets.symmetric(vertical: 8);
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            artUri.toString(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.graphic_eq_rounded,
            ),
          ),
        ),
      ),
    );
  }
}
