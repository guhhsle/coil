import 'package:flutter/material.dart';
import '../audio/handler.dart';
import '../layers/media.dart';
import '../audio/queue.dart';
import '../media/media.dart';
import '../data.dart';

class SongTile extends StatelessWidget {
  final Media media;
  final bool haptic;

  const SongTile({
    super.key,
    required this.media,
    this.haptic = true,
  });
  @override
  Widget build(BuildContext context) {
    //if (haptic && i % 2 == 0) HapticFeedback.selectionClick();
    return ListenableBuilder(
      listenable: MediaHandler(),
      builder: (context, child) {
        bool selected = MediaHandler().selected(media);
        Color primary = Theme.of(context).colorScheme.primary;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 256),
          margin: EdgeInsets.symmetric(
            horizontal: selected ? 12 : 0,
            vertical: selected ? 0 : 2,
          ),
          decoration: BoxDecoration(
            color: selected ? primary.withOpacity(0.4) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: selected ? 2 : 0,
              color: selected ? primary : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: selected ? primary.withOpacity(0.7) : Colors.transparent,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: SongTileChild(media: media, selected: selected),
        );
      },
    );
  }
}

class SongTileChild extends StatelessWidget {
  final bool selected;
  final Media media;

  const SongTileChild({
    super.key,
    required this.selected,
    required this.media,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          MediaHandler().load(media.queue);
          MediaHandler().skipToMedia(media);
        },
        onLongPress: () => MediaLayer(media).show(),
        leading: media.image(),
        title: Text(
          '${media.title}${!media.offline && Pref.artist.value ? ' - ${media.artist}' : ''}',
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: selected ? Theme.of(context).colorScheme.surface : null,
          ),
        ),
      ),
    );
  }
}
