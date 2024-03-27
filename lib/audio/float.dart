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
      builder: (context, snapIndex, widget) {
        return ValueListenableBuilder<int>(
          valueListenable: Handler().current,
          builder: (context, snapIndex, widget) {
            return StreamBuilder<Object>(
              stream: Handler().player.playbackStateStream,
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
                        onTap: () => Handler().swap(),
                        borderRadius: BorderRadius.circular(12),
                        child: (Handler().queuePlaying.isEmpty)
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
                                  child: pf['songThumbnails'] &&
                                          Handler().queuePlaying[snapIndex].extras['offline'] == null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            Handler().queuePlaying[snapIndex].artUri.toString(),
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
