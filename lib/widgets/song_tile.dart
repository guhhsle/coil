import 'package:coil/audio/queue.dart';
import 'package:coil/media/sheet.dart';
import 'package:flutter/material.dart';
import '../audio/handler.dart';
import '../data.dart';
import '../media/media.dart';
import '../template/layer.dart';

class SongTile extends StatelessWidget {
  final List<Media> list;
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
      valueListenable: MediaHandler.refreshQueue,
      builder: (context, val, child) {
        bool selected = MediaHandler().selected(list[i]);
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
  final List<Media> list;
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          MediaHandler().load(list);
          MediaHandler().skipTo(i);
        },
        onLongPress: () => showSheet(
          scroll: true,
          func: list[i].layer,
          param: null,
        ),
        leading: list[i].image(),
        title: Text(
          '${list[i].title}${!list[i].offline && pf['artist'] ? ' - ${list[i].artist}' : ''}',
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: selected ? Theme.of(context).colorScheme.surface : null,
          ),
        ),
      ),
    );
  }
}
