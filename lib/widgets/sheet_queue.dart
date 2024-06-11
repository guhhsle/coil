import 'package:coil/audio/queue.dart';
import 'package:flutter/material.dart';
import '../audio/handler.dart';
import '../media/audio.dart';
import '../audio/audio_slider.dart';
import '../audio/top_icon.dart';
import '../media/media.dart';
import '../template/custom_card.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import 'song_tile.dart';

class SheetQueue extends StatefulWidget {
  const SheetQueue({super.key});

  @override
  State<SheetQueue> createState() => _SheetQueueState();
}

class _SheetQueueState extends State<SheetQueue> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.2,
        maxChildSize: 0.85,
        builder: (context, controller) {
          return ValueListenableBuilder(
            valueListenable: MediaHandler.refreshQueue,
            builder: (context, snapshot, child) {
              return Card(
                margin: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
                              (c) => MediaHandler().shuffle(),
                            ),
                            margin: const EdgeInsets.only(
                                left: 16, right: 4, bottom: 12, top: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 16),
                          child: IconButton(
                            tooltip: t('Repeat'),
                            color: Theme.of(context).colorScheme.primary,
                            icon: Icon(
                              MediaHandler().loop
                                  ? Icons.repeat_one_rounded
                                  : Icons.wrap_text_rounded,
                            ),
                            onPressed: () {
                              MediaHandler().loop = !MediaHandler().loop;
                              setState(() {});
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12, top: 16, right: 8),
                          child: TopIcon(
                            top: false,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const AudioSlider(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Scrollbar(
                          controller: controller,
                          child: ListView.builder(
                            controller: controller,
                            physics: scrollPhysics,
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: MediaHandler().queuePlaying.length,
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
                                  Media item = MediaHandler().queuePlaying[i];
                                  bool e = i == MediaHandler().index;
                                  MediaHandler().removeItemAt(i);
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    item.insertToQueue(i - 1, e: e);
                                  }
                                  setState(() {});
                                },
                                key: Key(MediaHandler().queuePlaying[i].id),
                                child: SongTile(
                                    list: MediaHandler().queuePlaying, i: i),
                              );
                            },
                          ),
                        ),
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
