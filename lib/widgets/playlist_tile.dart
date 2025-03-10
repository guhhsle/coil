import 'package:flutter/material.dart';
import '../playlist/playlist.dart';
import '../playlist/artist.dart';
import '../pages/playlist.dart';
import '../pages/artist.dart';
import '../data.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile(this.playlist, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: playlist,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: Pref.thumbnails.value
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        playlist.isEmpty
                            ? playlist.thumbnail
                            : playlist[0].thumbnail ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) =>
                            const Icon(Icons.clear_all_rounded),
                      ),
                    ),
                  ),
                )
              : null,
          title: Text(playlist.name),
          onTap: () async => await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                if (playlist is Artist) {
                  return PageArtist(playlist as Artist);
                } else {
                  return PlaylistPage(playlist);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
