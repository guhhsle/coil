import 'package:flutter/material.dart';
import '../playlist/playlist.dart';
import '../pages/playlist.dart';
import '../pages/artist.dart';
import '../data.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile({
    super.key,
    required this.playlist,
  });

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
                        playlist.thumbnail,
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
                if (playlist is ArtistPlaylist) {
                  return PageArtist(artistPlaylist: playlist as ArtistPlaylist);
                } else {
                  return PlaylistPage(playlist: playlist);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
