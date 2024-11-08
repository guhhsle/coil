import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'playlist.dart';
import 'map.dart';
import '../pages/subscriptions.dart';
import '../media/media.dart';
import '../data.dart';

const tabs = ['Videos', 'Other'];

class Artist extends Playlist {
  Artist(super.url);
  String _tab = 'Videos';
  Map videos = {}, playlists = {};
  List displayed = [];

  String get tab => _tab;
  set tab(String newTab) {
    _tab = newTab;
    formatDisplayed();
  }

  static Artist fromMap(Map map) {
    final artist = Artist(map['id'] ?? map['url']);
    artist.loadFromMap(map);
    return artist;
  }

  bool get isSubscribed {
    int i = userSubscriptions.value.indexWhere((e) {
      return e['url'].contains(url);
    });
    return i >= 0;
  }

  Future<void> unSubscribeCache() async {
    File file = File('${Pref.appDirectory.value}/subscriptions.json');
    List list = jsonDecode(await file.readAsString());
    if (isSubscribed) {
      list.removeWhere((e) => e['url'].contains(url));
    } else {
      list.add({
        'url': '/channel/${videos['id']}',
        'name': videos['name'],
        'avatar': videos['avatarUrl'],
        'verified': true,
      });
    }
    list.sort((a, b) {
      return a['name'].compareTo(b['name']);
    });
    await file.writeAsString(jsonEncode(list));
    await fetchSubscriptions(false);
  }

  Future<void> refreshInfo() async {
    await unSubscribeCache();
    await unSubscribeCache();
  }

  Future<void> unSubscribe() async {
    if (Pref.token.value == '') {
      await unSubscribeCache();
    } else {
      await post(
        Uri.https(
          Pref.authInstance.value,
          '${isSubscribed ? 'un' : ''}subscribe',
        ),
        headers: {
          'Authorization': Pref.token.value,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'channelId': videos['id']}),
      );
      await fetchSubscriptions(true);
    }
    notify();
  }

  Future<void> loadContent() async {
    try {
      Response result = await get(Uri.https(Pref.instance.value, url));
      videos = jsonDecode(utf8.decode(result.bodyBytes));
      formatDisplayed();
      refreshInfo();
      result = await get(
        Uri.https(
          Pref.instance.value,
          'channels/tabs',
          {'data': (jsonDecode(result.body)['tabs'][0])['data']},
        ),
      );
      playlists = jsonDecode(utf8.decode(result.bodyBytes));
    } catch (e) {
      //INVALID CHANNEL
    }
    formatDisplayed();
  }

  void formatDisplayed() {
    Iterable maps = [];
    if (tab == 'Videos') {
      maps = videos['relatedStreams'] ?? [];
    } else {
      maps = playlists['content'] ?? [];
    }
    displayed = maps.map((map) {
      if (map['type'] == 'stream') {
        return Media.from(queue: this, map: map);
      } else {
        return Playlist.fromMap(map);
      }
    }).toList();
    list = displayed.whereType<Media>().toList();
    notify();
  }

  @override
  get length => displayed.length;
  get subscribers => videos['subscriberCount'];
}
