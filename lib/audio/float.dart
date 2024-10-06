import 'package:flutter/material.dart';
import 'handler.dart';
import '../widgets/sheet_queue.dart';
import '../threads/main_thread.dart';
import '../data.dart';

class Float extends StatelessWidget {
  const Float({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MediaHandler.refreshQueue,
      builder: (context, non, widget) {
        if (Pref.player.value != 'Floating') return Container();
        if (MediaHandler().queuePlaying.isEmpty) return Container();
        return SizedBox(
          width: 80,
          height: 80,
          child: InkWell(
            onLongPress: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const SheetQueue(),
            ),
            onTap: () => MainThread.callFn({'swap': null}),
            borderRadius: BorderRadius.circular(12),
            child:
                MediaHandler().current.image(padding: const EdgeInsets.all(12)),
          ),
        );
      },
    );
  }
}
