import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'media/media.dart';
import 'playlist/playlist.dart';

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
  'backgroundDark': 'Ultramarine',
  'primary': 'Black',
  'primaryDark': 'Light Green',
  //HOME
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
    'Albums',
    'Playlists',
    'Artists',
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

const Map<String, Color> colors = {
  'White': Colors.white,
  'Ivory': Color(0xFFf6f7eb),
  //'Beige': const Color(0xFFf5f5dc),
  'Pink': Color(0xFFFEDBD0),
  'Gruv Light': Color(0xFFC8A58A),
  'Light Green': Color(0xFFcbe2d4),
  'PinkRed': Color(0xFFee7674),
  'BlueGrey': Colors.blueGrey,
  'Dark BlueGrey': Color(0xFF263238),
  'Dark Green': Color(0xFF25291C),
  'Purple Grey': Color(0xFF282a36),
  'Ultramarine': Color(0xFF01161E),
  'Dark Pink': Color(0xFF442C2E),
  'Purple': Color(0xFF170a1c),
  'Gruv Dark': Color(0xFF0F0A0A),
  'Anchor': Color(0xFF11150D),
  'Black': Colors.black,
};

const Map<String, IconData> iconsTheme = {
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

late final SharedPreferences prefs;
const ScrollPhysics scrollPhysics = BouncingScrollPhysics(
  parent: AlwaysScrollableScrollPhysics(),
);

List<Media> queuePlaying = [];
List<Media> queueLoading = [];

Map l = {};
final navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<List> userPlaylists = ValueNotifier([]);
final ValueNotifier<List<FileSystemEntity>> localMusic = ValueNotifier([]);
final ValueNotifier<List<Playlist>> bookmarks = ValueNotifier([]);
final ValueNotifier<List> userSubscriptions = ValueNotifier([]);
final ValueNotifier<List> trendingVideos = ValueNotifier([]);
final ValueNotifier<List> searchResults = ValueNotifier([]);
final ValueNotifier<List> searchSuggestions = ValueNotifier([]);
final ValueNotifier<String> currentLyrics = ValueNotifier('');

final ValueNotifier<bool> showTopDock = ValueNotifier(false);
final ValueNotifier<bool> refreshLay = ValueNotifier(true);
final ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData());
final ValueNotifier<int> current = ValueNotifier(0);
final ValueNotifier<PageController> controller = ValueNotifier(PageController());
final ValueNotifier<bool> refreshPlaylist = ValueNotifier(false);
final ValueNotifier<bool> refreshQueue = ValueNotifier(false);
