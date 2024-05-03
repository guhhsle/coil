import 'package:coil/settings/account.dart';
import 'package:coil/settings/data.dart';
import 'package:coil/settings/interface.dart';
import 'package:coil/template/theme.dart';
import 'package:flutter/material.dart';
import 'media/media.dart';
import 'playlist/playlist.dart';
import 'settings/more.dart';
import 'template/layer.dart';

Map pf = {
  //APP
  //'firstBoot': true,
  'bookmarks': <String>[],
  //ACCOUNT
  'username': '',
  'password': '',
  'token': '',
  'instance': 'Set instance',
  'authInstance': '',
  'location': 'United States',
  //MORE
  'volume': 50,
  'locale': 'en',
  //INTERFACE
  //'reverse': true,
  'artist': false,
  'appbar': 'Black',
  'player': 'Dock',
  'background': 'Ivory',
  'backgroundDark': 'Ultramarine',
  'primary': 'Black',
  'primaryDark': 'Light Green',
  //HOME
  'homeOrder': [
    'Playlists',
    'Offline',
    'Bookmarks',
    'Feed',
    'Trending',
    'Subscriptions',
  ],
  'searchOrder': [
    'Songs',
    'Videos',
    'Albums',
    'Playlists',
    'Artists',
    'Music playlists',
  ],
  'tags': 'Top',
  //'grid': 0,
  'sortBy': 'Name',
  //DATA
  'indie': true,
  'bitrate': 180000,
  'thumbnails': true,
  //'songThumbnails': true,
  'timeLimit': 8,
  'searchHistory': <String>[],
  'instanceHistory': <String>[],
  'searchHistoryLimit': 100,
  //CONSTANTS
  'lyricsApi': 'hyperpipeapi.onrender.com',
  'watchOnPiped': 'https://piped.video/watch?v=',
  'musicFolder': '/sdcard/Music',
  'appDirectory': '',
  'font': 'JetBrainsMono',
  'requestLimit': 50,
  //CONTINUE-LISTENING
  'rememberThreshold': 10,
  'rememberLimit': 100,
  'rememberURLs': <String>[],
  'rememberTimes': <String>[],
};

final List<Setting> settings = [
  Setting('More', Icons.segment_rounded, '', (c) => showSheet(func: moreSet)),
  Setting('Account', Icons.person_rounded, '', (c) => showSheet(func: accountSet)),
  Setting('Data', Icons.cloud_rounded, '', (c) => showSheet(func: dataSet)),
  Setting('Interface', Icons.toggle_on, '', (c) => showSheet(func: interfaceSet)),
  Setting('Primary', Icons.colorize_rounded, '', (c) => showSheet(func: themeMap, param: true, scroll: true)),
  Setting('Background', Icons.colorize_rounded, '', (c) => showSheet(func: themeMap, param: false, scroll: true)),
];

final ValueNotifier<List> userPlaylists = ValueNotifier([]);
final ValueNotifier<List<Media>> localMusic = ValueNotifier([]);
final ValueNotifier<List<Playlist>> bookmarks = ValueNotifier([]);
final ValueNotifier<List<Media>> userFeed = ValueNotifier([]);
final ValueNotifier<List> userSubscriptions = ValueNotifier([]);
final ValueNotifier<List<Media>> trendingVideos = ValueNotifier([]);
final ValueNotifier<String> currentLyrics = ValueNotifier('');

final ValueNotifier<bool> showTopDock = ValueNotifier(false);
final ValueNotifier<bool> refreshPlaylist = ValueNotifier(false);
