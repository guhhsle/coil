import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/cache.dart';
import '../functions/other.dart';
import '../playlist/playlist.dart';
import 'thumbnail.dart';

class Bookmarks extends StatelessWidget {
  const Bookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchBookmarks,
      child: ValueListenableBuilder<List<Playlist>>(
        valueListenable: bookmarks,
        builder: (context, data, child) {
          return ListView(
            physics: scrollPhysics,
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  FutureBuilder(
                    future: Playlist.fromStorage('Bookmarks'),
                    builder: (context, snap) {
                      if (snap.hasError) return Container();
                      return Thumbnail(
                        url: 'Bookmarks',
                        thumbnail: '',
                        title: t('Bookmarks'),
                        playlist: true,
                        path: const [2],
                      );
                    },
                  ),
                  FutureBuilder(
                    future: Playlist.fromStorage('100'),
                    builder: (context, snap) {
                      if (snap.hasError) return Container();
                      return const Thumbnail(
                        url: '100',
                        thumbnail: '',
                        title: '100',
                        playlist: true,
                        path: [2],
                      );
                    },
                  ),
                  for (int i = 0; i < data.length; i++)
                    Thumbnail(
                      url: data[i].url,
                      thumbnail: data[i].thumbnail,
                      title: data[i].name,
                      playlist: true,
                      path: const [2, 0, 1],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
