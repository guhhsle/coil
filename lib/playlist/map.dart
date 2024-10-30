import 'playlist.dart';
import '../media/media.dart';
import '../data.dart';

extension PlaylistMap on Playlist {
  void fillListFromRaw() {
    List playlist = raw['relatedStreams'] ?? [];
    list = [];
    for (var i = 0; i < playlist.length; i++) {
      user = userPlaylists.value.indexWhere((el) => el['id'] == url) >= 0;
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
    thumbnail = map['thumbnailUrl'] ?? '';
    name = map['name'] ?? 'NAME';
    fillListFromRaw();
    notify();
  }
}
