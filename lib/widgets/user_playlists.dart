// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../data.dart';
import '../layer.dart';
import '../services/playlist.dart';
import 'thumbnail.dart';

class UserPlaylists extends StatelessWidget {
  const UserPlaylists({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => fetchUserPlaylists(true),
      child: ValueListenableBuilder<List>(
        valueListenable: userPlaylists,
        builder: (context, snap, child) {
          return ListView(
            physics: scrollPhysics,
            padding: const EdgeInsets.only(bottom: 32, top: 16),
            children: [
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < snap.length; i++)
                    Thumbnail(
                      url: snap[i]['id'],
                      thumbnail: snap[i]['thumbnail'],
                      title: snap[i]['name'],
                      playlist: true,
                      user: true,
                      path: const [2, 1],
                    ),
                  const CreatePlaylist(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class CreatePlaylist extends StatelessWidget {
  const CreatePlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    if (pf['grid'] == 0) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: l['Create a playlist'],
          onPressed: () => showSheet(
            func: (non) => Layer(
              action: Setting(
                'Create a playlist',
                Icons.playlist_add_rounded,
                '',
                (c) async => await createPlaylist().then((v) => Navigator.of(c).pop()),
              ),
              list: [],
            ),
          ),
        ),
      );
    } else {
      double width = MediaQuery.of(context).size.width / (pf['grid'] == 1 ? 1.2 : (pf['grid'] + 0.5));
      return SizedBox(
        height: pf['grid'] == 1 ? (width / (16 / 9)) : width,
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showSheet(
            func: (non) => Layer(
              action: Setting(
                'Create a playlist',
                Icons.playlist_add_rounded,
                '',
                (c) async => await createPlaylist().then((v) => Navigator.of(c).pop()),
              ),
              list: [],
            ),
          ),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      );
    }
  }
}
