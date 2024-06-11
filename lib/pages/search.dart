import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data.dart';
import '../functions/other.dart';
import '../media/http.dart';
import '../media/media.dart';
import '../template/custom_chip.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/prefs.dart';
import '../widgets/frame.dart';
import '../widgets/playlist_tile.dart';
import '../widgets/song_tile.dart';

String query = '';
Map<String, String> filters = {};
String? filter;
List suggestions = [];
ScrollController searchScrollController = ScrollController();

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

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<StatefulWidget> createState() => SearchState();
}

class SearchState extends State<Search> {
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
    super.initState();
  }

  TextEditingController searchController = TextEditingController(text: query);

  @override
  Widget build(BuildContext context) {
    return Frame(
      title: TextFormField(
        controller: searchController,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        decoration: InputDecoration(
          counterText: "",
          hintText: t('Search'),
          hintStyle: TextStyle(
            color:
                Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.5),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (title) {
          query = title;
          setState(() {});
        },
        onFieldSubmitted: rememberSearch,
      ),
      actions: [
        IconButton(
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
                      (c) {
                        query = history[i];
                        searchController.text = query;
                        setState(() {});
                      },
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
      ],
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
                controller: searchScrollController,
                itemBuilder: (context, i) => CustomChip(
                  onSelected: (val) {
                    filter = filters.values.toList()[i];
                    if (calculateShift(context, i, filters) != null) {
                      searchScrollController.animateTo(
                        calculateShift(context, i, filters)!,
                        duration: const Duration(milliseconds: 256),
                        curve: Curves.easeOutQuad,
                      );
                    }
                    setState(() {});
                  },
                  label: filters.keys.toList()[i],
                  selected: filter == filters.values.toList()[i],
                ),
              ),
            ),
          ),
          FutureBuilder(
            key: Key("RESULT-$query"),
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
                      if (item['uploaderName'] == 'YouTube Music') {
                        return Container();
                      }
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
    );
  }
}
