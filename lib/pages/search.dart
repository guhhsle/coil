import 'dart:async';

import 'package:coil/layer.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../functions/other.dart';
import '../functions/prefs.dart';
import '../functions/song.dart';
import '../http/other.dart';
import '../http/playlist.dart';
import '../widgets/body.dart';
import '../widgets/song_tile.dart';
import '../widgets/thumbnail.dart';

class Delegate extends SearchDelegate {
  @override
  buildLeading(BuildContext context) {
    if (query.isEmpty) {
      return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );
    } else {
      return IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.close_rounded),
      );
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      const TopIcon(),
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: () {
            List<String> history = pf['searchHistory'];
            showSheet(
              scroll: true,
              func: (non) => Layer(
                action: Setting(
                  'Clear',
                  Icons.clear_all_rounded,
                  '',
                  (c) {
                    setPref('searchHistory', <String>[]);
                    Navigator.of(c).pop();
                  },
                ),
                list: [
                  for (int i = 0; i < history.length; i++)
                    Setting(
                      history[i],
                      Icons.remove_rounded,
                      '',
                      (c) => query = history[i],
                      secondary: (c) {
                        List<String> l = pf['searchHistory'];
                        setPref('searchHistory', l..removeAt(i), refresh: true);
                        //searchPress(true, context);
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  @override
  appBarTheme(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
          bodyColor: Theme.of(context).appBarTheme.foregroundColor,
        );

    return Theme.of(context).copyWith(
      textTheme: textTheme,
      inputDecorationTheme: Theme.of(context).inputDecorationTheme.copyWith(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
      hintColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        shadowColor: Colors.transparent,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SuggestionList(
      query: query,
      result: true,
      key: Key(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SuggestionList(
      query: query,
      result: false,
      key: Key(query),
    );
  }
}

class SuggestionList extends StatefulWidget {
  final String query;
  final bool result;

  const SuggestionList({
    super.key,
    required this.query,
    required this.result,
  });
  @override
  SuggestionListState createState() => SuggestionListState();
}

String? filter;

class SuggestionListState extends State<SuggestionList> {
  List suggestions = [];
  late String query;
  late bool result;
  ScrollController scrollController = ScrollController();

  IconData icon(String option, sel) {
    return {
      'Songs': sel ? Icons.music_note_rounded : Icons.music_note_outlined,
      'Videos': sel ? Icons.movie_rounded : Icons.movie_outlined,
      'Playlists': sel ? Icons.video_library_rounded : Icons.video_library_outlined,
      'Artists': sel ? Icons.person_rounded : Icons.person_outlined,
      'Albums': sel ? Icons.album_rounded : Icons.album_outlined,
      'Music playlists': sel ? Icons.my_library_music_rounded : Icons.my_library_music_outlined,
    }[option]!;
  }

  Map<String, String> filters = {
    'Songs': 'music_songs',
    'Videos': 'videos',
    'Playlists': 'playlists',
    'Artists': 'channels',
    'Albums': 'music_albums',
    'Music playlists': 'music_playlists',
  };

  List<String> options = pf['searchOrder'];

  @override
  initState() {
    filter ??= filters[options[0]] ?? 'music_songs';
    query = widget.query;
    result = widget.result;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (result) {
      rememberSearch(query);
      unawaited(search(query, filter ?? 'music_songs'));
      result = false;
    }
    return Scaffold(
      floatingActionButton: const Float(),
      body: Body(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  children: [
                    for (String option in options)
                      IconButton(
                        icon: Icon(icon(option, filter == filters[option])),
                        tooltip: t(option),
                        onPressed: () {
                          filter = filters[option];
                          result = true;
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<List>(
              valueListenable: searchResults,
              builder: (context, snap, child) {
                if (snap.isEmpty) return Container();
                queueLoading.clear();
                if (filter == 'music_songs' || filter == 'videos') {
                  try {
                    for (var q = 0; q < snap.length; q++) {
                      queueLoading.add(mapToMedia(snap[q]));
                    }
                    unawaited(preload(range: 10));
                    return Expanded(
                      child: ListView.builder(
                        physics: scrollPhysics,
                        itemCount: snap.length,
                        itemBuilder: (context, i) => SongTile(
                          list: queueLoading,
                          i: i,
                          haptic: false,
                        ),
                      ),
                    );
                  } catch (e) {
                    //FORMATTING ISSUE
                    return Container();
                  }
                } else {
                  return Expanded(
                    child: ListView(
                      physics: scrollPhysics,
                      padding: const EdgeInsets.only(bottom: 32, top: 16),
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            for (int i = 0; i < snap.length; i++)
                              Builder(
                                builder: (context) {
                                  String title = '';
                                  try {
                                    title = snap[i]['name'] ?? snap[i]['title'];
                                  } catch (e) {
                                    debugPrint(e.toString());
                                  }
                                  if (snap[i]['uploaderName'] == 'YouTube Music') return Container();
                                  return Thumbnail(
                                    thumbnail: snap[i]['thumbnail'],
                                    title: title,
                                    playlist: filter != 'channels',
                                    url: snap[i]['url'],
                                    path: const [0, 1],
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
/*
double? calculateShift(BuildContext context, int index) {
  double tagsLength = pf['locale'] == 'ja' ? 28 : 22;
  double wantedShift = index == 0 ? 0 : 28;
  double word = pf['locale'] == 'ja' ? 14 : 8.45;
  double width = MediaQuery.of(context).size.width;
  for (int i = 0; i < filters.length; i++) {
    tagsLength += 36 + (l[filters.keys.elementAt(i)] as String).length * word;
  }
  for (int i = 0; i < index - 1; i++) {
    wantedShift += 36 + (l[filters.keys.elementAt(i)] as String).length * word;
  }
  double maxShift = 40 + tagsLength - width;

  if (wantedShift < maxShift) {
    return wantedShift;
  } else if (tagsLength > width) {
    return maxShift;
  } else {
    return null;
  }
}
*/
