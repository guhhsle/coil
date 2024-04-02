import 'package:flutter/material.dart';
import '../data.dart';
import '../functions/other.dart';
import '../pages/artist.dart';
import '../pages/playlist.dart';

class PlaylistTile extends StatelessWidget {
  final Map info;
  final bool playlist;
  final List<int> path;

  const PlaylistTile({
    super.key,
    required this.info,
    required this.playlist,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: pf['thumbnails']
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      info['thumbnail'] ?? info['avatar'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Icon(Icons.clear_all_rounded),
                    ),
                  ),
                ),
              )
            : null,
        title: Text(formatName(info['title'] ?? info['name'] ?? t(info['url']))),
        onTap: () async => await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              if (playlist) {
                return PlaylistPage(url: formatUrl(info['id'] ?? info['url']), path: path);
              } else {
                return PageArtist(url: info['url'], artist: info['name']);
              }
            },
          ),
        ),
      ),
    );
  }
}
