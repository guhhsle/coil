import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:coil/playlist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map pf = {
  //APP
  'firstBoot': true,
  'bookmarks': <String>[],
  //ACCOUNT
  'username': '',
  'password': '',
  'token': '',
  'instance': '',
  'authInstance': '',
  'location': 'United States',
  //MORE
  'volume': 50,
  'locale': 'en',
  //INTERFACE
  'reverse': true,
  'artist': false,
  'appbar': 'Black',
  'player': 'Dock',
  'background': 'Ivory',
  'primary': 'Black',
  //HOME
  //'start': 'Playlists',
  'homeOrder': [
    'Playlists',
    'Offline',
    'Bookmarks',
    'Subscriptions',
    'Trending',
  ],
  'searchOrder': [
    'Songs',
    'Videos',
    'Playlists',
    'Artists',
    'Albums',
    'Music playlists',
  ],
  'tags': 'Top',
  'grid': 0,
  'sortBy': 'Name',
  //DATA
  'indie': true,
  'bitrate': 180000,
  'thumbnails': true,
  'songThumbnails': true,
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

final Map<String, Color> colors = {
  'White': Colors.white,
  'Ivory': const Color(0xFFf6f7eb),
  //'Beige': const Color(0xFFf5f5dc),
  'Pink': const Color(0xFFFEDBD0),
  'Gruv Light': const Color(0xFFC8A58A),
  'Light Green': const Color(0xFFcbe2d4),
  'PinkRed': const Color(0xFFee7674),
  'BlueGrey': Colors.blueGrey,
  'Dark BlueGrey': Colors.blueGrey.shade900,
  'Dark Green': const Color(0xFF25291C),
  'Purple Grey': const Color(0xFF282a36),
  'Ultramarine': const Color(0xFF01161E),
  'Dark Pink': const Color(0xFF442C2E),
  'Purple': const Color(0xFF170a1c),
  'Gruv Dark': const Color(0xFF0F0A0A),
  'Anchor': const Color(0xFF11150D),
  'Black': Colors.black,
};

final Map<String, IconData> iconsTheme = {
  'White': Icons.ac_unit_rounded,
  'Ivory': Icons.ac_unit_rounded,
  'Pink': Icons.spa_outlined,
  'Gruv Light': Icons.local_cafe_outlined,
  'Light Green': Icons.nature_outlined,
  'PinkRed': Icons.spa_outlined,
  'BlueGrey': Icons.filter_drama_rounded,
  'Dark BlueGrey': Icons.filter_drama_rounded,
  'Dark Green': Icons.nature_outlined,
  'Purple Grey': Icons.light,
  'Ultramarine': Icons.water_rounded,
  'Dark Pink': Icons.spa_outlined,
  'Purple': Icons.star_purple500_rounded,
  'Gruv Dark': Icons.local_cafe_outlined,
  'Anchor': Icons.anchor_outlined,
  'Black': Icons.nights_stay_outlined,
};

Map l = {};

late final SharedPreferences prefs;

final ValueNotifier<List> userPlaylists = ValueNotifier([]);
final ValueNotifier<List<FileSystemEntity>> localMusic = ValueNotifier([]);
final ValueNotifier<List<Playlist>> bookmarks = ValueNotifier([]);
final ValueNotifier<List> userSubscriptions = ValueNotifier([]);
final ValueNotifier<List> trendingVideos = ValueNotifier([]);
final ValueNotifier<List> searchResults = ValueNotifier([]);
final ValueNotifier<List> searchSuggestions = ValueNotifier([]);
final ValueNotifier<String> currentLyrics = ValueNotifier('');

final ValueNotifier<bool> showTopDock = ValueNotifier(false);

final navigatorKey = GlobalKey<NavigatorState>();

List<MediaItem> queuePlaying = [];
List<MediaItem> queueLoading = [];

final ValueNotifier<bool> refreshLay = ValueNotifier(true);
const ScrollPhysics scrollPhysics = BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData());
final ValueNotifier<int> current = ValueNotifier(0);
final ValueNotifier<PageController> controller = ValueNotifier(PageController());
final ValueNotifier<bool> refreshPlaylist = ValueNotifier(false);
final ValueNotifier<bool> refreshQueue = ValueNotifier(false);

late Playlist bookmarksPlaylist;
