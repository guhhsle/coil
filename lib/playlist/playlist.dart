import '../functions/other.dart';
import '../media/media.dart';
import '../template/data.dart';
import '../template/functions.dart';
import 'cache.dart';
import 'http.dart';

class Playlist {
  String url, thumbnail, name, uploader;
  Map raw;
  int items;
  List<Media> list;

  Playlist({
    required this.url,
    required this.name,
    required this.list,
    required this.uploader,
    required this.items,
    required this.thumbnail,
    required this.raw,
  });

  static Playlist fromString(String url) {
    return Playlist(
      url: url,
      thumbnail: '',
      list: [],
      uploader: 'Local',
      items: 0,
      name: t(url),
      raw: {'relatedStreams': <Map>[]},
    );
  }

  static Future<Playlist> load(
    String url,
    List<int> path, {
    int timeTried = 0,
  }) async {
    url = formatUrl(url);
    Playlist? list;
    for (int i in path) {
      try {
        if (i == 2) {
          list = await PlaylistCache.from(url);
        } else {
          list = await PlaylistHTTP.from(url, i == 1);
        }
        return list;
      } catch (e) {
        //
      }
    }
    if (timeTried < 4 && list == null) {
      return load(url, path, timeTried: ++timeTried);
    } else {
      return Playlist.fromString(url);
    }
  }

  bool isCacheOnly() => playlistIsCacheOnly(name);
}

const List<String> userFiles = ['Bookmarks', '100', '100raw'];

bool playlistIsCacheOnly(String url) {
  if (pf['token'] == '') return true;
  if (userFiles.contains(url)) return true;
  return false;
}
