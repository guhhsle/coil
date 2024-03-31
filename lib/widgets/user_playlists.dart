import 'package:flutter/material.dart';
import '../data.dart';
import '../http/playlist.dart';
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
          onPressed: () async => createPlaylist(),
        ),
      );
    } else {
      double width = MediaQuery.of(context).size.width / (pf['grid'] == 1 ? 1.2 : (pf['grid'] + 0.5));
      return SizedBox(
        height: pf['grid'] == 1 ? (width / (16 / 9)) : width,
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async => createPlaylist(),
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
