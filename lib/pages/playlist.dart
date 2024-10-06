import 'dart:async';
import 'package:coil/layers/playlist_options.dart';
import 'package:flutter/material.dart';
import '../audio/queue.dart';
import '../data.dart';
import '../functions/other.dart';
import '../media/http.dart';
import '../audio/handler.dart';
import '../functions/generate.dart';
import '../playlist/http.dart';
import '../playlist/playlist.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../widgets/frame.dart';
import '../widgets/song_tile.dart';

class PlaylistPage extends StatefulWidget {
  final String url;
  final List<int> path;

  const PlaylistPage({
    Key? key,
    required this.url,
    required this.path,
  }) : super(key: key);

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  bool generating = false;
  late Playlist list;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshPlaylist,
      builder: (context, snapshot, child) {
        return FutureBuilder(
          future: Playlist.load(widget.url, widget.path),
          builder: (context, snap) {
            if (!snap.hasData) return const Frame();
            list = snap.data!;
            unawaited(list.list.preload(0, 10));
            return Frame(
              title: TextFormField(
                maxLines: 1,
                maxLength: 24,
                initialValue: formatName(list.name),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onFieldSubmitted: (title) => list.rename(title),
              ),
              actions: [
                if (generating)
                  IconButton(
                    onPressed: () {},
                    icon: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    ),
                  )
                else
                  IconButton(
                    tooltip: t('Generate similar'),
                    onPressed: () {
                      setState(() => generating = true);
                      //compute(
                      generate([
                        list.list,
                        Pref.instance.value,
                        Pref.indie.value,
                      ]).then((value) {
                        MediaHandler().load(value);
                        MediaHandler().skipTo(0);
                        setState(() => generating = false);
                      });
                    },
                    icon: const Icon(Icons.track_changes_rounded),
                  ),
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: t('Menu'),
                  onPressed: () {
                    PlaylistOptions(list, widget.path.toList()).show();
                  },
                ),
              ],
              child: RefreshIndicator(
                onRefresh: () async {
                  List<int> path = widget.path.toList()..remove(2);
                  list = await Playlist.load(widget.url, path);
                  setState(() {});
                },
                child: ListView.builder(
                  physics: scrollPhysics,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: list.list.length,
                  itemBuilder: (context, i) => SongTile(list: list.list, i: i),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
