/*
import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/other.dart';
import '../pages/page_artist.dart';
import '../pages/playlist_page.dart';

class Thumbnail extends StatelessWidget {
  final String url, thumbnail, title;
  final bool playlist, user;
  final List<int> path;
  const Thumbnail({
    super.key,
    required this.url,
    required this.thumbnail,
    required this.title,
    required this.playlist,
    required this.path,
    this.user = false,
  });

  @override
  Widget build(BuildContext context) {
    if (pf['grid'] == 0) {
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
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.clear_all_rounded),
                      ),
                    ),
                  ),
                )
              : null,
          title: Text(formatList(title)),
          onTap: () async => await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                if (playlist) {
                  return PlaylistPage(url: formatUrl(url), path: path, user: user);
                } else {
                  return PageArtist(url: url, artist: title);
                }
              },
            ),
          ),
        ),
      );
    } else {
      late double width, height;
      if (pf['grid'] == 1) {
        width = MediaQuery.of(context).size.width / 1.2;
        height = width / (16 / 9) + 32;
      } else {
        width = MediaQuery.of(context).size.width / (pf['grid'] + 0.5);
        height = width + 32;
      }
      return SizedBox(
        height: height,
        width: width,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async => await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    if (playlist) {
                      return PlaylistPage(url: formatUrl(url), path: path, user: user);
                    } else {
                      return PageArtist(url: url, artist: title);
                    }
                  },
                ),
              ),
              child: AspectRatio(
                aspectRatio: width / (height - 32),
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: pf['thumbnails']
                        ? Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Image.network(
                                thumbnail,
                                fit: BoxFit.cover,
                                height: height - 32,
                                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.clear_all_rounded)),
                              ),
                              Container(
                                color: Theme.of(context).colorScheme.background.withOpacity(0.4),
                                height: 32,
                                child: Center(
                                  child: Text(
                                    title.replaceAll('Playlist - ', ''),
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Container(
                            height: MediaQuery.of(context).size.width / 3,
                            width: MediaQuery.of(context).size.width / 3,
                            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 30),
                            child: Center(
                              child: Text(
                                formatList(title),
                                style: const TextStyle(
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
*/
