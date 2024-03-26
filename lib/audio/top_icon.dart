import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../widgets/sheet_queue.dart';

class TopIcon extends StatelessWidget {
  final bool top;
  final Color? color;
  const TopIcon({super.key, this.top = true, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, snapIndex, widget) {
        return ValueListenableBuilder<int>(
          valueListenable: current,
          builder: (context, snapIndex, widget) {
            return StreamBuilder(
              stream: stateStream,
              builder: (context, snapshot) {
                if (top && queuePlaying.isNotEmpty && pf['player'] == 'Top dock') {
                  return ValueListenableBuilder(
                    valueListenable: showTopDock,
                    builder: (context, data, ch) {
                      return IconButton(
                        icon: Icon(data ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                        onPressed: () => showTopDock.value = !showTopDock.value,
                      );
                    },
                  );
                } else if (!top || (pf['player'] == 'Top' && queuePlaying.isNotEmpty)) {
                  ProcessingState? state = snapshot.data?.processingState;
                  return InkWell(
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const SheetQueue(),
                    ),
                    child: IconButton(
                      onPressed: () => player.playing ? handler.pause() : handler.play(),
                      icon: Icon(
                        !snapshot.hasData
                            ? Icons.stop_rounded
                            : (state == ProcessingState.buffering || state == ProcessingState.loading)
                                ? Icons.language_rounded
                                : snapshot.data!.playing
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                        color: color ?? Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          },
        );
      },
    );
  }
}
