import 'package:flutter/material.dart';

import '../data.dart';
import '../layer.dart';
import '../services/audio.dart';
import '../services/sheets.dart';
import 'sheet_queue.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  BottomPlayerState createState() => BottomPlayerState();
}

class BottomPlayerState extends State<BottomPlayer> {
  @override
  Widget build(BuildContext context) {
    bool td = pf['player'] == 'Top dock';
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, snapIndex, widget) {
        return StreamBuilder(
          stream: stateStream,
          builder: (context, snapshot) {
            return AnimatedContainer(
              key: const Key('cont'),
              curve: Curves.easeOutQuad,
              duration: Duration(milliseconds: td ? 128 : 256),
              height: queuePlaying.isEmpty ? 0 : 64,
              width: double.infinity,
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: ValueListenableBuilder<int>(
                valueListenable: current,
                builder: (context, snapIndex, widget) {
                  if (queuePlaying.isEmpty) return Container();
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: InkWell(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const SheetQueue(),
                          ),
                          onLongPress: () => showSheet(
                            scroll: true,
                            func: mediaToMap,
                            param: queuePlaying[current.value],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          child: Card(
                            margin: EdgeInsets.zero,
                            color: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).appBarTheme.foregroundColor!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: pf['songThumbnails'] && queuePlaying[snapIndex].extras!['offline'] == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        queuePlaying[snapIndex].artUri.toString(),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.graphic_eq_rounded,
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<PageController>(
                          valueListenable: controller,
                          builder: (context, controllerSnapshot, widget) {
                            return PageView(
                              key: Key(controllerSnapshot.hashCode.toString()),
                              controller: controllerSnapshot,
                              onPageChanged: (int newP) => skipTo(newP),
                              physics: const BouncingScrollPhysics(),
                              children: [
                                for (int i = 0; i < queuePlaying.length; i++)
                                  SizedBox(
                                    height: 64,
                                    width: 164,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        queuePlaying[i].title,
                                        style: TextStyle(
                                          color: Theme.of(context).appBarTheme.foregroundColor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      const TopIcon(top: false),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
