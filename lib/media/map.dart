import 'dart:math';

import '../data.dart';
import 'media.dart';

extension MediaMap on Media {
  Map toMap() {
    return {
      'url': id.replaceAll('/watch?v=', ''),
      'title': title,
      'thumbnail': artUri.toString(),
      'uploaderName': artist,
      'uploaderUrl': uploaderUrl,
    };
  }

  static Media fromMap(Map json, {int i = 10, String? playlist}) {
    i = i < 10 ? 10 - i : 0;
    return Media(
      title: json['title'],
      id: json['url'].replaceAll('/watch?v=', ''),
      artUri: json['thumbnail'] ?? '',
      artist: (json['uploaderName'] ?? json['uploader']).replaceAll(' - Topic', ''),
      uploaderUrl: json['uploaderUrl'] ?? '',
      quality: evaluateSong(json, i),
      index: i,
      playlist: playlist,
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
