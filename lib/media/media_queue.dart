import 'package:flutter/material.dart';
import '../data.dart';
import 'media.dart';
import 'http.dart';

class MediaQueue with ChangeNotifier {
  List<Media> list;
  bool user = false;
  MediaQueue([List<Media>? list]) : list = list ?? [];

  void notify() => notifyListeners();

  void clear({bool notify = true}) {
    list.clear();
    if (notify) notifyListeners();
  }

  int get length => list.length;
  Media operator [](int index) => list[index];
  bool get isEmpty => list.isEmpty;
  void add(Media media, {bool notify = true}) {
    list.add(media);
    if (notify) notifyListeners();
  }

  void insert(int i, Media media, {bool notify = true}) {
    list.insert(i, media);
    if (notify) notifyListeners();
  }

  void sort({int Function(Media, Media)? compare, bool notify = true}) {
    list.sort(compare);
    if (notify) notifyListeners();
  }

  void setList(Iterable<Media> medias, {bool notify = true}) {
    list = medias.toList();
    if (notify) notifyListeners();
  }

  Media removeAt(int i, {bool notify = true}) {
    final media = list.removeAt(i);
    if (notify) notifyListeners();
    return media;
  }

  void shuffle({bool notify = true}) {
    list.shuffle();
    if (notify) notifyListeners();
  }

  int indexOf(Media media) {
    int i = list.indexOf(media);
    if (i < 0) i = list.indexWhere((e) => e.id == media.id);
    return i;
  }

  Future<void> preload(int from, int to) async {
    var futures = <Future>[];
    for (int i = from; i < to && i < Pref.maxPreload.value; i++) {
      if (i >= 0 && i < length) {
        futures.add(this[i].load());
      }
    }
    await Future.wait(futures);
  }

  bool contains(Media media) {
    int index = list.indexOf(media);
    return index != -1;
  }
}
