import 'media.dart';
import '../playlist/cache.dart';
import '../data.dart';

extension MediaCache on Media {
  Future<void> addTo100() async {
    await top100Raw.load();
    await top100Raw.forceAddMediaToCache(this, top: true);
    Map<String, int> map = {};
    if (top100Raw.list.length > 100) top100Raw.list.removeLast();
    await top100Raw.backup();
    await top100.load();
    top100.list = top100Raw.list.toList();

    for (final media in top100.list) {
      if (map.containsKey(media.id)) {
        map[media.id] = map[media.id]! + 1;
      } else {
        map.addAll({media.id: 1});
      }
    }
    top100.list.sort(
      (a, b) => map[b.id]!.compareTo(map[a.id]!),
    );
    for (int i = 0; i < top100.length; i++) {
      if (map[top100[i].id]! > 1) {
        map[top100[i].id] = map[top100[i].id]! - 1;
        top100.list.removeAt(i);
        i--;
      }
    }
    await top100.backup();
  }
}
