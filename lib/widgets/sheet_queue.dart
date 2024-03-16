import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/audio.dart';
import '../layer.dart';
import 'custom_card.dart';
import 'song_tile.dart';

class SheetQueue extends StatefulWidget {
  const SheetQueue({super.key});

  @override
  State<SheetQueue> createState() => _SheetQueueState();
}

class _SheetQueueState extends State<SheetQueue> {
  Map<LoopMode, IconData> m = {
    LoopMode.off: Icons.wrap_text_rounded,
    LoopMode.one: Icons.repeat_one_rounded,
    LoopMode.all: Icons.repeat,
  };
  @override
  Widget build(BuildContext context) {
    queueLoading = queuePlaying.toList();
    return Container(
      color: Colors.transparent,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.85,
        builder: (_, controller) {
          return ValueListenableBuilder(
            valueListenable: refreshQueue,
            builder: (context, snapshot, child) {
              return Card(
                margin: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.background.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomCard(
                            Setting(
                              'Shuffle',
                              Icons.low_priority_rounded,
                              '',
                              (c) {
                                shuffle();
                                setState(() {});
                              },
                            ),
                            margin: const EdgeInsets.only(left: 16, right: 4, bottom: 12, top: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 16),
                          child: IconButton(
                            tooltip: l['Repeat ${loop.name}'],
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icon(m[loop]!),
                            onPressed: () {
                              loop = m.keys.elementAt((m.keys.toList().indexOf(loop) + 1) % 3);
                              setState(() {});
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 16, right: 8),
                          child: TopIcon(
                            top: false,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const AudioSlider(),
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: current,
                        builder: (context, data, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Scrollbar(
                              controller: controller,
                              child: ListView.builder(
                                controller: controller,
                                physics: scrollPhysics,
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                itemCount: queuePlaying.length,
                                itemBuilder: (context, i) {
                                  return Dismissible(
                                    background: Container(
                                      color: Colors.blue,
                                      child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 32),
                                          child: Icon(
                                            Icons.arrow_upward_rounded,
                                            color: Color(0xFF282a36),
                                          ),
                                        ),
                                      ),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.red,
                                      child: const Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 32),
                                          child: Icon(
                                            Icons.delete_rounded,
                                            color: Color(0xFF282a36),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onDismissed: (direction) {
                                      MediaItem item = queuePlaying[i];
                                      bool e = i == current.value;
                                      removeItemAt(i);
                                      if (direction == DismissDirection.startToEnd) {
                                        insertItemToQueue(i - 1, item, e: e);
                                      }
                                      setState(() {});
                                    },
                                    key: Key(queuePlaying[i].id),
                                    child: SongTile(list: queuePlaying, i: i),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
