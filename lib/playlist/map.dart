import 'package:coil/playlist/playlist.dart';

import '../data.dart';
import '../media/media.dart';

extension PlaylistMap on Playlist {
  static List<Media> listFromMap(Map json, String url) {
    List playlist = json['relatedStreams'] ?? [];
    List<Media> list = [];
    for (var i = 0; i < playlist.length; i++) {
      int index = userPlaylists.value.indexWhere((el) => el['id'] == url);
      if (url == 'Bookmarks') index++;
      if (pf['reverse'] && index >= 0) {
        list.insert(
          0,
          Media.from(
            playlist[i],
            playlist: index >= 0 ? url : null,
            i: i,
          ),
        );
      } else {
        list.add(Media.from(
          playlist[i],
          playlist: index >= 0 ? url : null,
          i: i,
        ));
      }
    }
    return list;
  }

  static Playlist from(Map json, String url) {
    List<Media> list = listFromMap(json, url);
    return Playlist(
      url: url,
      name: json['name'] ?? 'NAME',
      thumbnail: json['thumbnailUrl'] ?? '',
      list: list,
      uploader: json['uploader'] ?? json['uploaderName'] ?? 'UPLOADER',
      items: list.length,
      raw: json,
    );
  }

  String fromattedName() {
    return name.contains('Album ') ? name.replaceRange(0, 8, '') : name;
  }
}
