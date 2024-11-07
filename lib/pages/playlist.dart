import 'package:flutter/material.dart';
import '../layers/playlist_options.dart';
import '../functions/generate.dart';
import '../template/functions.dart';
import '../media/media_queue.dart';
import '../playlist/playlist.dart';
import '../widgets/song_tile.dart';
import '../functions/other.dart';
import '../playlist/http.dart';
import '../audio/handler.dart';
import '../template/data.dart';
import '../widgets/frame.dart';
import '../audio/queue.dart';
import '../data.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;
  const PlaylistPage(this.playlist, {super.key});

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  bool generating = false;
  Playlist get playlist => widget.playlist;

  @override
  void initState() {
    playlist.load().then((_) => playlist.preload(0, 10));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: playlist,
      builder: (context, child) => Frame(
        title: TextFormField(
          key: Key(playlist.name),
          maxLines: 1,
          maxLength: 24,
          initialValue: formatName(playlist.name),
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
          onFieldSubmitted: (title) => playlist.rename(title),
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
                  playlist.list,
                  Pref.instance.value,
                  Pref.indie.value,
                ]).then((value) {
                  MediaHandler().load(MediaQueue(value));
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
              PlaylistOptions(playlist).show();
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () => playlist.load(force: true),
          child: ListView.builder(
            physics: scrollPhysics,
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            itemCount: playlist.length,
            itemBuilder: (context, i) => SongTile(media: playlist[i]),
          ),
        ),
      ),
    );
  }
}
