import 'package:flutter/material.dart';

import '../audio/queue.dart';
import '../media/audio.dart';
import '../audio/audio_slider.dart';
import '../audio/handler.dart';
import '../audio/top_icon.dart';
import '../data.dart';
import '../layer.dart';
import '../media/media.dart';
import 'custom_card.dart';
import 'song_tile.dart';

class SheetQueue extends StatefulWidget {
  const SheetQueue({super.key});

  @override
  State<SheetQueue> createState() => _SheetQueueState();
}

class _SheetQueueState extends State<SheetQueue> {
  @override
  Widget build(BuildContext context) {
    Handler().queueLoading = Handler().queuePlaying.toList();
    return Container(
      color: Colors.transparent,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.85,
        builder: (_, controller) {
          return ValueListenableBuilder(
            valueListenable: Handler().refreshQueue,
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
                                Handler().shuffle();
                                setState(() {});
                              },
                            ),
                            margin: const EdgeInsets.only(left: 16, right: 4, bottom: 12, top: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 16),
                          child: IconButton(
                            tooltip: l['Repeat ${Handler().loop.name}'],
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icon({
                              LoopMode.off: Icons.wrap_text_rounded,
                              LoopMode.one: Icons.repeat_one_rounded,
                              LoopMode.all: Icons.repeat,
                            }[Handler().loop]!),
                            onPressed: () {
                              Handler().loop =
                                  LoopMode.values[(LoopMode.values.toList().indexOf(Handler().loop) + 1) % 3];
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
                        valueListenable: Handler().current,
                        builder: (context, data, child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Scrollbar(
                              controller: controller,
                              child: ListView.builder(
                                controller: controller,
                                physics: scrollPhysics,
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                itemCount: Handler().queuePlaying.length,
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
                                      Media item = Handler().queuePlaying[i];
                                      bool e = i == Handler().current.value;
                                      Handler().removeItemAt(i);
                                      if (direction == DismissDirection.startToEnd) {
                                        item.insertToQueue(i - 1, e: e);
                                      }
                                      setState(() {});
                                    },
                                    key: Key(Handler().queuePlaying[i].id),
                                    child: SongTile(list: Handler().queuePlaying, i: i),
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
