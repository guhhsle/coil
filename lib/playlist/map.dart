import 'playlist.dart';
import '../template/functions.dart';
import '../functions/other.dart';
import '../media/media.dart';
import '../data.dart';

extension PlaylistMap on Playlist {
  void fillListFromRaw() {
    List playlist = raw['relatedStreams'] ?? [];
    list = [];
    for (var i = 0; i < playlist.length; i++) {
      user = userPlaylists.value.indexWhere((p) => p.url == url) >= 0;
      //TODO test if (url == 'Bookmarks') user = true;
      if (userFiles.contains(url)) user = true;
      if (user) {
        insert(
          0,
          Media.from(map: playlist[i], queue: this, i: i),
          notify: false,
        );
      } else {
        list.add(Media.from(map: playlist[i], queue: this, i: i));
      }
    }
  }

  void loadFromMap(Map map) {
    raw = map;
    uploader = map['uploader'] ?? map['uploaderName'] ?? '';
    thumbnail = map['thumbnailUrl'] ?? map['thumbnail'] ?? map['avatar'] ?? '';
    name = formatName(map['name'] ?? t(url));
    fillListFromRaw();
    notify();
  }
}
