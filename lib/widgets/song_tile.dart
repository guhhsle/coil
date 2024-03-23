import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../functions/sheets.dart';
import '../layer.dart';
import '../song.dart';

class SongTile extends StatelessWidget {
  final List<Song> list;
  final int i;
  final bool haptic;

  const SongTile({
    super.key,
    required this.list,
    required this.i,
    this.haptic = true,
  });
  @override
  Widget build(BuildContext context) {
    //if (haptic && i % 2 == 0) HapticFeedback.selectionClick();
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, val, child) {
        bool selected = queuePlaying.length > current.value && list[i].id == queuePlaying[current.value].id;
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
          child: SongTileChild(list: list, i: i, selected: selected),
        );
      },
    );
  }
}

class SongTileChild extends StatelessWidget {
  final List<Song> list;
  final int i;
  final bool selected;

  const SongTileChild({
    super.key,
    required this.list,
    required this.i,
    required this.selected,
  });
  @override
  Widget build(BuildContext context) {
    bool web = list[i].extras!['offline'] == null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          load(list);
          skipTo(i);
        },
        onLongPress: () => showSheet(
          scroll: true,
          func: mediaToLayer,
          param: list[i],
        ),
        leading: songImage(list[i]),
        title: Text(
          web && pf['artist'] ? '${list[i].title} - ${list[i].artist}' : list[i].title,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: selected ? Theme.of(context).colorScheme.background : null,
          ),
        ),
      ),
    );
  }
}

Widget? songImage(Song item, {EdgeInsets? padding, force = false}) {
  if (!force) {
    if (!pf['songThumbnails']) return null;
    if (item.extras!['offline'] != null) return null;
  }
  padding ??= const EdgeInsets.symmetric(vertical: 8);
  return Padding(
    padding: padding,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          item.artUri.toString(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.graphic_eq_rounded,
          ),
        ),
      ),
    ),
  );
}
