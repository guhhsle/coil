import 'dart:math';
import 'media_queue.dart';
import 'media.dart';
import 'http.dart';
import '../functions/other.dart';
import '../data.dart';

extension MediaMap on Media {
  Map toMap() {
    return {
      'url': formatUrl(id),
      'title': title,
      'thumbnail': artUri.toString(),
      'uploaderName': artist,
      'uploaderUrl': uploaderUrl,
    };
  }

  static Media fromMap({
    required MediaQueue queue,
    required Map map,
    int i = 10,
  }) {
    return Media(
      title: map['title'],
      id: formatUrl(map['url']),
      thumbnail: map['thumbnail'] ?? '',
      artist: formatName(map['uploaderName'] ?? map['uploader']),
      uploaderUrl: map['uploaderUrl'] ?? '',
      quality: evaluateSong(map, i),
      queue: queue,
      index: i,
    );
  }

  static int evaluateSong(Map m, int? i) {
    int eval = i == -10 ? 20 + Random().nextInt(16) : 0;
    String name = m['title'].toLowerCase() ?? '';
    const badWords = [
      ...['-', '|', 'lyrics', 'mix', 'video'],
      ...['playlist', 'hits', 'songs'],
    ];
    for (String slur in badWords) {
      if (name.contains(slur)) return Pref.indie.value ? 1 : 5;
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
    if (Pref.indie.value) eval ~/= 5;
    return eval;
  }
}
