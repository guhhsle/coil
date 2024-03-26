import 'media.dart';

extension MediaMap on Media {
  Map toMap() {
    return {
      'url': id.replaceAll('/watch?v=', ''),
      'title': title,
      'thumbnail': artUri.toString(),
      'uploaderName': artist,
      'uploaderUrl': extras!['uploaderUrl'],
    };
  }
}
