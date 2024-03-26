import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../widgets/sheet_queue.dart';

class Float extends StatelessWidget {
  const Float({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, snapIndex, widget) {
        return ValueListenableBuilder<int>(
          valueListenable: current,
          builder: (context, snapIndex, widget) {
            return StreamBuilder<Object>(
              stream: stateStream,
              builder: (context, snapshot) {
                if (pf['player'] == 'Floating') {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: InkWell(
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const SheetQueue(),
                          );
                        },
                        onTap: () => player.playing ? handler.pause() : handler.play(),
                        borderRadius: BorderRadius.circular(12),
                        child: (queuePlaying.isEmpty)
                            ? Container()
                            : Card(
                                margin: EdgeInsets.zero,
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: pf['songThumbnails'] && queuePlaying[snapIndex].extras!['offline'] == null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            queuePlaying[snapIndex].artUri.toString(),
                                            fit: BoxFit.cover,
                                            height: 24,
                                            width: 24,
                                          ),
                                        )
                                      : Container(
                                          height: 24,
                                          width: 24,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                ),
                              ),
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
