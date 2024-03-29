import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

import '../data.dart';
import 'map.dart';

class Media extends Metadata {
  String id;
  int quality, index, reps;
  bool offline;
  String? audioUrl, playlist, uploaderUrl, lyrics;
  Map<String, int> audioUrls;
  List<Map> videoUrls;

  Media({
    required this.id,
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
    super.artUri,
    super.artist,
  });

  static Media from(Map json, {int? i, String? playlist}) {
    return MediaMap.fromMap(json, i: i ?? 10, playlist: playlist);
  }

  Widget? image({EdgeInsets? padding, force = false}) {
    if (!force) {
      if (!pf['songThumbnails']) return null;
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
