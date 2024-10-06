import 'package:flutter/material.dart';
import 'handler.dart';
import '../data.dart';
import '../threads/main_thread.dart';
import '../widgets/sheet_queue.dart';
import '../template/theme.dart';

class TopIcon extends StatelessWidget {
  final bool top;
  final Color? color;
  const TopIcon({super.key, this.top = true, this.color});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemePref(),
      builder: (context, child) {
        return ValueListenableBuilder(
          valueListenable: MediaHandler().processing,
          builder: (context, processing, child) {
            return ValueListenableBuilder(
              valueListenable: MediaHandler().playing,
              builder: (context, playing, child) {
                if (MediaHandler().queuePlaying.isEmpty) {
                  return Container();
                } else if (!top || Pref.player.value == 'Top') {
                  late IconData status;
                  if (processing == 'loading') {
                    status = Icons.language_rounded;
                  } else if (playing) {
                    status = Icons.stop_rounded;
                  } else {
                    status = Icons.play_arrow_rounded;
                  }

                  return InkWell(
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const SheetQueue(),
                    ),
                    child: IconButton(
                      onPressed: () => MainThread.callFn({'swap': null}),
                      icon: Icon(
                        status,
                        color: color ??
                            Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    ),
                  );
                } else if (Pref.player.value == 'Top dock') {
                  return ValueListenableBuilder(
                    valueListenable: showTopDock,
                    builder: (context, data, ch) {
                      return IconButton(
                        icon: Icon(data
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded),
                        onPressed: () => showTopDock.value = !showTopDock.value,
                      );
                    },
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
