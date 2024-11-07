import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../widgets/playlist_tile.dart';
import '../template/tile_chip.dart';
import '../template/functions.dart';
import '../widgets/song_tile.dart';
import '../playlist/playlist.dart';
import '../media/media_queue.dart';
import '../functions/other.dart';
import '../template/tile.dart';
import '../template/data.dart';
import '../widgets/frame.dart';
import '../layers/search.dart';
import '../playlist/map.dart';
import '../media/media.dart';
import '../data.dart';

String query = '';
Map<String, String> filters = {};
String? filter;
List suggestions = [];
ScrollController searchScrollController = ScrollController();

Future<List> search(String query, String filter) async {
  Response response = await get(Uri.https(Pref.instance.value, 'search', {
    'q': query,
    'filter': filter,
  }));
  return jsonDecode(utf8.decode(response.bodyBytes))['items'] ?? [];
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
        Pref.searchOrder.value[i]: {
          'Songs': 'music_songs',
          'Videos': 'videos',
          'Playlists': 'playlists',
          'Artists': 'channels',
          'Albums': 'music_albums',
          'Music playlists': 'music_playlists',
        }[Pref.searchOrder.value[i]]!
      });
    }
    filter ??= filters[Pref.searchOrder.value[0]] ?? 'music_songs';
    super.initState();
  }

  TextEditingController searchController = TextEditingController(text: query);

  @override
  Widget build(BuildContext context) {
    return Frame(
      automaticallyImplyLeading: query == '',
      title: Row(
        children: [
          query != ''
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    query = '';
                    searchController.text = '';
                    setState(() {});
                  },
                )
              : Container(),
          SizedBox(width: query == '' ? 0 : 16),
          Expanded(
            child: TextFormField(
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
                  color: Theme.of(context)
                      .appBarTheme
                      .foregroundColor!
                      .withOpacity(0.5),
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
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded),
          onPressed: () {
            SearchLayer((oldQuery) {
              query = oldQuery;
              searchController.text = query;
              setState(() {});
            }).show();
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
                itemBuilder: (context, i) => TileChip(
                  showAvatar: false,
                  selected: filter == filters.values.toList()[i],
                  tile: Tile(
                    filters.keys.elementAt(i),
                    Icons.history_rounded,
                    '',
                    () => setState(() {
                      filter = filters.values.elementAt(i);
                      if (calculateShift(context, i, filters) != null) {
                        searchScrollController.animateTo(
                          calculateShift(context, i, filters)!,
                          duration: const Duration(milliseconds: 256),
                          curve: Curves.easeOutQuad,
                        );
                      }
                    }),
                  ),
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
                  final songs = MediaQueue([]);
                  songs.setList(result.map((map) {
                    return Media.from(map: map, queue: songs);
                  }), notify: false);
                  songs.preload(0, 10);
                  return Expanded(
                    child: ListView.builder(
                      physics: scrollPhysics,
                      itemCount: result.length,
                      itemBuilder: (context, i) => SongTile(
                        media: songs[i],
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
                      Map map = result[i];
                      if (map['uploaderName'] == 'YouTube Music') {
                        return Container();
                      }
                      if (filter == 'channels') {
                        return PlaylistTile(
                          playlist: ArtistPlaylist.fromMap(map),
                        );
                      } else {
                        final playlist = Playlist(map['id'] ?? map['url']);
                        playlist.loadFromMap(map);
                        return PlaylistTile(playlist: playlist);
                      }
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
