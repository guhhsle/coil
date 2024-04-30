import 'package:flutter/material.dart';
import '../data.dart';
import '../template/data.dart';
import 'handler.dart';
import '../threads/main_thread.dart';
import '../widgets/sheet_queue.dart';

class TopIcon extends StatelessWidget {
  final bool top;
  final Color? color;
  const TopIcon({super.key, this.top = true, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, non, child) {
        return ValueListenableBuilder(
          valueListenable: MediaHandler().processing,
          builder: (context, processing, child) {
            return ValueListenableBuilder(
              valueListenable: MediaHandler().playing,
              builder: (context, playing, child) {
                if (MediaHandler().queuePlaying.isEmpty) {
                  return Container();
                } else if (!top || pf['player'] == 'Top') {
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
                        color: color ?? Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    ),
                  );
                } else if (pf['player'] == 'Top dock') {
                  return ValueListenableBuilder(
                    valueListenable: showTopDock,
                    builder: (context, data, ch) {
                      return IconButton(
                        icon: Icon(data ? Icons.expand_less_rounded : Icons.expand_more_rounded),
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
