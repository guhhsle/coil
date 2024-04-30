import 'package:flutter/material.dart';
import 'media/media.dart';
import 'playlist/playlist.dart';

final ValueNotifier<List> userPlaylists = ValueNotifier([]);
final ValueNotifier<List<Media>> localMusic = ValueNotifier([]);
final ValueNotifier<List<Playlist>> bookmarks = ValueNotifier([]);
final ValueNotifier<List<Media>> userFeed = ValueNotifier([]);
final ValueNotifier<List> userSubscriptions = ValueNotifier([]);
final ValueNotifier<List<Media>> trendingVideos = ValueNotifier([]);
final ValueNotifier<String> currentLyrics = ValueNotifier('');

final ValueNotifier<bool> showTopDock = ValueNotifier(false);
final ValueNotifier<bool> refreshPlaylist = ValueNotifier(false);
