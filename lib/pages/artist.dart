import 'package:flutter/material.dart';
import '../widgets/playlist_tile.dart';
import '../template/tile_chip.dart';
import '../widgets/song_tile.dart';
import '../playlist/artist.dart';
import '../template/data.dart';
import '../template/tile.dart';
import '../widgets/frame.dart';
import '../media/media.dart';

class PageArtist extends StatelessWidget {
  final Artist artist;
  const PageArtist(this.artist, {super.key});

  @override
  Widget build(BuildContext context) {
    artist.loadContent();
    return ListenableBuilder(
      listenable: artist,
      builder: (context, child) => Frame(
        title: Text(artist.name),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 64,
              child: ListView(
                physics: scrollPhysics,
                scrollDirection: Axis.horizontal,
                children: [
                  for (final tab in tabs)
                    TileChip(
                      selected: artist.tab == tab,
                      showAvatar: false,
                      tile: Tile(tab, Icons.filter_rounded, '', () {
                        artist.tab = tab;
                      }),
                    ),
                  TileChip(
                    selected: artist.isSubscribed,
                    showCheckmark: true,
                    showAvatar: false,
                    tile: Tile(
                      artist.subscribers,
                      Icons.numbers_rounded,
                      '',
                      artist.unSubscribe,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: artist.loadContent,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32, top: 16),
                  physics: scrollPhysics,
                  itemCount: artist.length,
                  itemBuilder: (context, i) {
                    if (artist.displayed[i] is Media) {
                      return SongTile(media: artist.displayed[i]);
                    } else {
                      return PlaylistTile(artist.displayed[i]);
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
