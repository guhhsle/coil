import 'package:coil/playlist/playlist.dart';
import '../data.dart';
import '../media/media.dart';

extension PlaylistMap on Playlist {
  static List<Media> listFromMap(Map json, String url) {
    List playlist = json['relatedStreams'] ?? [];
    List<Media> list = [];
    for (var i = 0; i < playlist.length; i++) {
      bool userCreated = userPlaylists.value.indexWhere((el) => el['id'] == url) >= 0;
      if (url == 'Bookmarks') userCreated = true;
      if (userCreated) {
        list.insert(
          0,
          Media.from(
            playlist[i],
            playlist: url,
            i: i,
          ),
        );
      } else {
        list.add(Media.from(playlist[i], i: i));
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
}
