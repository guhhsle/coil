import 'package:flutter/material.dart';
import 'layers/settings/interface.dart';
import 'layers/settings/account.dart';
import 'layers/settings/other.dart';
import 'layers/settings/data.dart';
import 'media/media_queue.dart';
import 'playlist/playlist.dart';
import 'functions/other.dart';
import 'template/theme.dart';
import 'template/prefs.dart';
import 'template/tile.dart';

const locales = [
  ...['Serbian', 'English', 'Spanish', 'German', 'French', 'Italian'],
  ...['Polish', 'Portuguese', 'Russian', 'Slovenian', 'Japanese'],
];
const tops = ['Primary', 'Black', 'Transparent'];
const playerPos = ['Dock', 'Top', 'Top dock', 'Floating'];
const initHome = [
  ...['Playlists', 'Offline', 'Bookmarks'],
  ...['Feed', 'Trending', 'Subscriptions'],
];
const allTags = ['Hide', 'Top', 'Bottom'];
const allSortBy = [
  ...['Name', 'Name <', 'Length'],
  ...['Length <', 'Default', 'Default <'],
];
const initSearchOrder = [
  ...['Songs', 'Videos', ' Albums'],
  ...['Playlists', 'Artists', 'Music playlists'],
];

enum Pref<T> {
  //TEMPLATE
  font('Font', 'JetBrainsMono', Icons.format_italic_rounded, ui: true),
  locale('Language', 'English', Icons.language_rounded, ui: true, all: locales),
  appbar('Top', 'Black', Icons.gradient_rounded, all: tops, ui: true),
  background('Background', 'F0F8FF', Icons.tonality_rounded, ui: true),
  primary('Primary', '000000', Icons.colorize_rounded, ui: true),
  backgroundDark('Dark background', '0F0A0A', Icons.tonality_rounded, ui: true),
  primaryDark('Dark primary', 'FEDBD0', Icons.colorize_rounded, ui: true),
  debug('Developer', false, Icons.code_rounded),
  //ACCOUNT
  bookmarks('Bookmarks', <String>[], Icons.bookmarks_rounded, ui: true),
  username('Username', '', Icons.person_rounded),
  password('Password', '', Icons.password_rounded),
  token('Token', '', Icons.token_rounded),
  instance('Instance', 'Set instance', Icons.domain_rounded, ui: true),
  authInstance('Auth instance', '', Icons.domain_rounded, ui: true),
  location('Country', 'United States', Icons.language_rounded),
  //MORE
  volume('Volume', 50, Icons.graphic_eq_rounded),
  artist('Show artist', false, Icons.person_rounded),
  player('Player', 'Dock', Icons.toggle_on, ui: true, all: playerPos),
  homeOrder('Home', initHome, Icons.door_front_door_rounded, ui: true),
  tags('Tags', 'Top', Icons.label_rounded, all: allTags, ui: true),
  sortBy('Sort', 'Name', Icons.sort_rounded, all: allSortBy, ui: true),
  bitrate('Quality', 180000, Icons.cloud_rounded),
  thumbnails('Thumbnails', true, Icons.image_rounded, ui: true),
  indie('Recommend less popular', true, Icons.track_changes_rounded),
  timeLimit('Recommend timeout (s)', 8, Icons.track_changes_rounded),
  searchOrder('Seach', initSearchOrder, Icons.fiber_manual_record_outlined),
  musicFolder('Music folder', '/sdcard/Music', Icons.folder_rounded, ui: true),
  rememberThreshold('Remember threshold', 10, Icons.timelapse_rounded),
  rememberTimes(null, <String>[], null),
  rememberURLs(null, <String>[], null),
  rememberLimit(null, 100, null),
  requestLimit(null, 50, null),
  appDirectory(null, '', null),
  alternative('Alternative', 'piped.video', Icons.tv_rounded),
  lyricsAPI(null, 'hyperpipeapi.onrender.com', null),
  searchHistoryLimit(null, 100, null),
  instanceHistory('Instances', <String>[], Icons.domain_rounded),
  searchHistory('Search history', <String>[], Icons.history_rounded, ui: true),
  ;

  final T initial;
  final List<T>? all;
  final String? title;
  final IconData? icon;
  final bool ui; //Changing it leads to UI rebuild

  const Pref(this.title, this.initial, this.icon, {this.all, this.ui = false});

  T get value => Preferences.get(this);

  Future set(T val) => Preferences.set(this, val);

  Future rev() => Preferences.rev(this);

  Future next() => Preferences.next(this);

  void nextByLayer({suffix = ''}) => NextByLayer(this, suffix: suffix).show();

  @override
  String toString() => name;
}

List<Tile> get settings {
  return [
    Tile('More', Icons.segment_rounded, '', OtherLayer().show),
    Tile('Account', Icons.person_rounded, '', AccountLayer().show),
    Tile('Data', Icons.cloud_rounded, '', DataLayer().show),
    Tile('Interface', Icons.toggle_on, '', InterfaceLayer().show),
    Tile('Primary', Icons.colorize_rounded, '', ThemeLayer(true).show),
    Tile('Background', Icons.tonality_rounded, '', ThemeLayer(false).show),
  ];
}

final trendingVideos = MediaQueue([]);
final localMusic = MediaQueue([]);
final userFeed = MediaQueue([]);
final allBookmarks = ValueNotifier(<Playlist>[]);
final userSubscriptions = ValueNotifier([]);
final currentLyrics = ValueNotifier('');
final userPlaylists = ValueNotifier(<Playlist>[]);
final bookmarks = Playlist('Bookmarks')..path = [2];
final top100 = Playlist('100')..path = [2];
final top100Raw = Playlist('100raw')..path = [2];

List<Playlist> get allPlaylists {
  return [
    ...userPlaylists.value,
    bookmarks,
    top100,
    top100Raw,
  ];
}

final showTopDock = ValueNotifier(false);
//final refreshPlaylist = ValueNotifier(false);

final homeMap = <String, Widget>{};
String selectedHome = 'Playlists';
final barText = ValueNotifier(formatInstanceName(Pref.instance.value));
final pageController = PageController();
final scrollController = ScrollController();
final key = GlobalKey(debugLabel: 'Tags');
