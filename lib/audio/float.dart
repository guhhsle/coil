import 'package:flutter/material.dart';
import 'player.dart';
import '../data.dart';
import '../widgets/sheet_queue.dart';
import 'handler.dart';

class Float extends StatelessWidget {
  const Float({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Handler().refreshQueue,
      builder: (context, non, widget) {
        return ValueListenableBuilder<int>(
          valueListenable: Handler().current,
          builder: (context, snapIndex, widget) {
            return StreamBuilder<Object>(
              stream: Handler().player.playbackStateStream,
              builder: (context, snapshot) {
                if (pf['player'] != 'Floating') return Container();
                if (Handler().queuePlaying.isEmpty) return Container();
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: InkWell(
                    onLongPress: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const SheetQueue(),
                    ),
                    onTap: () => Handler().swap(),
                    borderRadius: BorderRadius.circular(12),
                    child: Handler().queuePlaying[snapIndex].image(padding: const EdgeInsets.all(12)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
