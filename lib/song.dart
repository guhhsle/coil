import 'dart:math';

import 'package:audio_service/audio_service.dart';

import 'data.dart';

class Song extends MediaItem {
  Song({required super.id, required super.title, super.artUri, super.artist, super.extras});

  Map toMap() {
    return {
      'url': id.replaceAll('/watch?v=', ''),
      'title': title,
      'thumbnail': artUri.toString(),
      'uploaderName': artist,
      'uploaderUrl': extras!['uploaderUrl'],
    };
  }

  static Song from(Map json, {int? i, String? playlist}) {
    return Song(
      title: json['title'],
      id: json['url'].replaceAll('/watch?v=', ''),
      artUri: Uri.parse(json['thumbnail'] ?? ''),
      artist: (json['uploaderName'] ?? json['uploader']).replaceAll(' - Topic', ''),
      extras: {
        'url': '',
        'uploaderUrl': json['uploaderUrl'] ?? '',
        'verified': evaluateSong(json, i),
        'duration': json['duration'] ?? 0,
        'index': playlist != null
            ? i
            : i != null && i < 10
                ? 10 - i
                : 0,
        'reps': 1,
        'audioUrls': <String, int>{},
        'video': <Map>[],
        'playlist': playlist,
      },
    );
  }

  static int evaluateSong(Map m, int? i) {
    int eval = i == -10 ? 20 + Random().nextInt(16) : 0;
    String name = m['title'].toLowerCase() ?? '';
    List<String> badWords = [
      '-',
      '|',
      'lyrics',
      'mix',
      'video',
      'playlist',
      'hits',
      'songs',
    ];
    for (String slur in badWords) {
      if (name.contains(slur)) return pf['indie'] ? 1 : 5;
    }
    List<bool> parameters = [
      true, //m['views'] ?? -1 == -1 && m['uploaded'] ?? -1 == -1,
      m['uploaderVerified'] ?? false,
      (m['uploaderName'] ?? m['uploader']).endsWith(' - Topic'),
    ];
    for (int i = 0; i < parameters.length; i++) {
      if (parameters[i]) eval += i * i + 16;
    }
    if (eval > 40) eval = 40;
    if (pf['indie']) eval ~/= 5;
    return eval;
  }
}