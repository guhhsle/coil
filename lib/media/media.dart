import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'media_queue.dart';
import 'map.dart';
import '../data.dart';

class MediaLink {
  String url;
  int? bitrate;
  String? format, quality;

  MediaLink({
    required this.url,
    this.bitrate,
    this.format,
    this.quality,
  });

  static MediaLink from(Map e) {
    return MediaLink(
      url: e['url'],
      format: e['format'],
      quality: e['quality'],
      bitrate: e['bitrate'],
    );
  }
}

class Media extends MediaItem {
  int quality, index, reps;
  bool offline;
  String? audioUrl, uploaderUrl, lyrics;
  MediaQueue queue;
  List<MediaLink> audioUrls;
  List<MediaLink> videoUrls;

  Media({
    required this.queue,
    required super.id,
    this.quality = 10,
    this.index = 0,
    this.audioUrl,
    this.uploaderUrl,
    this.audioUrls = const [],
    this.lyrics,
    this.videoUrls = const [],
    this.offline = false,
    this.reps = 1,
    required super.title,
    super.duration,
    super.artUri,
    super.artist = '',
  });

  static Media from({
    required MediaQueue queue,
    required Map map,
    int? i,
  }) {
    return MediaMap.fromMap(map: map, i: i ?? 10, queue: queue);
  }

  static Media copyFrom(Media media, {MediaQueue? queue}) {
    return MediaMap.fromMap(
      queue: queue ?? media.queue,
      map: media.toMap(),
    );
  }

  Widget? image({EdgeInsets? padding, force = false}) {
    if (!force) {
      if (!Pref.thumbnails.value) return null;
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
