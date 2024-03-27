import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

import '../data.dart';
import 'map.dart';

class Media extends Metadata {
  String id;
  Map extras;

  Media({
    required this.id,
    required super.title,
    required this.extras,
    super.artUri,
    super.artist,
  });

  static Media from(Map json, {int? i, String? playlist}) {
    return MediaMap.fromMap(json, i: i, playlist: playlist);
  }

  Widget? image({EdgeInsets? padding, force = false}) {
    if (!force) {
      if (!pf['songThumbnails']) return null;
      if (extras['offline'] != null) return null;
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
