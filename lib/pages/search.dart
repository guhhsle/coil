import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data.dart';
import '../functions/other.dart';
import '../media/http.dart';
import '../audio/float.dart';
import '../audio/top_icon.dart';
import '../media/media.dart';
import '../template/custom_chip.dart';
import '../template/data.dart';
import '../template/layer.dart';
import '../template/prefs.dart';
import '../widgets/body.dart';
import '../widgets/playlist_tile.dart';
import '../widgets/song_tile.dart';

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
              func: (non) async => Layer(
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
                      secondary: (c) => setPref(
                        'searchHistory',
                        history..removeAt(i),
                        refresh: true,
                      ),
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

Map<String, String> filters = {};
String? filter;

class SuggestionListState extends State<SuggestionList> {
  List suggestions = [];
  late String query;
  late bool result;
  ScrollController scrollController = ScrollController();

  Future<List> search(String query, String filter) async {
    Response response = await get(
      Uri.https(
        pf['instance'],
        'search',
        {'q': query, 'filter': filter},
      ),
    );
    List? list = jsonDecode(utf8.decode(response.bodyBytes))['items'];
    return list ?? [];
  }

  @override
  initState() {
    filters.clear();
    for (int i = 0; i < 6; i++) {
      filters.addAll({
        pf['searchOrder'][i]: {
          'Songs': 'music_songs',
          'Videos': 'videos',
          'Playlists': 'playlists',
          'Artists': 'channels',
          'Albums': 'music_albums',
          'Music playlists': 'music_playlists',
        }[pf['searchOrder'][i]]!
      });
    }
    filter ??= filters[pf['searchOrder'][0]] ?? 'music_songs';
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
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  physics: scrollPhysics,
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  controller: scrollController,
                  itemBuilder: (context, i) => CustomChip(
                    onSelected: (val) {
                      filter = filters.values.toList()[i];
                      if (calculateShift(context, i, filters) != null) {
                        scrollController.animateTo(
                          calculateShift(context, i, filters)!,
                          duration: const Duration(milliseconds: 256),
                          curve: Curves.easeOutQuad,
                        );
                      }
                      result = true;
                      setState(() {});
                    },
                    label: filters.keys.toList()[i],
                    selected: filter == filters.values.toList()[i],
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: search(query, filter ?? 'music_songs'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                List result = snapshot.data ?? [];
                if (filter == 'music_songs' || filter == 'videos') {
                  try {
                    List<Media> songs = result.map((e) => Media.from(e)).toList();
                    unawaited(songs.preload(0, 10));
                    return Expanded(
                      child: ListView.builder(
                        physics: scrollPhysics,
                        itemCount: result.length,
                        itemBuilder: (context, i) => SongTile(
                          list: songs, // Handler().queueLoading,
                          i: i,
                          haptic: false,
                        ),
                      ),
                    );
                  } catch (e) {
                    return Container();
                  }
                } else {
                  return Expanded(
                    child: ListView.builder(
                      physics: scrollPhysics,
                      padding: const EdgeInsets.only(bottom: 32, top: 16),
                      itemCount: result.length,
                      itemBuilder: (context, i) {
                        Map item = result[i];
                        if (item['uploaderName'] == 'YouTube Music') return Container();
                        return PlaylistTile(
                          info: item,
                          playlist: filter != 'channels',
                          path: const [0, 1],
                        );
                      },
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
