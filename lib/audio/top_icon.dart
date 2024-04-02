import 'package:flutter/material.dart';

import 'player.dart';
import '../data.dart';
import '../widgets/sheet_queue.dart';
import 'handler.dart';

class TopIcon extends StatelessWidget {
  final bool top;
  final Color? color;
  const TopIcon({super.key, this.top = true, this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, non, child) {
        return StreamBuilder(
          stream: Handler().player.playbackStateStream,
          builder: (context, snapshot) => FutureBuilder(
            future: Handler().player.isPlaying,
            builder: (context, isPlaying) {
              if (Handler().queuePlaying.isEmpty) {
                return Container();
              } else if (!top || pf['player'] == 'Top') {
                return InkWell(
                  onLongPress: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const SheetQueue(),
                  ),
                  child: IconButton(
                    onPressed: () => Handler().swap(),
                    icon: Icon(
                      isPlaying.data ?? false ? Icons.stop_rounded : Icons.play_arrow_rounded,
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
          ),
        );
      },
    );
  }
}
