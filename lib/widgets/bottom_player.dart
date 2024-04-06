import 'package:flutter/material.dart';
import 'sheet_queue.dart';
import '../audio/queue.dart';
import '../data.dart';
import '../media/sheet.dart';
import '../audio/handler.dart';
import '../audio/top_icon.dart';
import '../layer.dart';

class BottomPlayer extends StatelessWidget {
  final bool show;
  const BottomPlayer({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show) return Container();
    return ValueListenableBuilder(
      valueListenable: showTopDock,
      builder: (context, showTop, non) {
        bool td = pf['player'] == 'Top dock';
        return ValueListenableBuilder(
          valueListenable: MediaHandler.refreshQueue,
          builder: (context, non, none) {
            return ValueListenableBuilder(
              valueListenable: MediaHandler().current,
              builder: (context, i, none) {
                return AnimatedContainer(
                  height: MediaHandler().queuePlaying.isEmpty || (td && !showTop) ? 0 : 64,
                  key: const Key('cont'),
                  duration: Duration(milliseconds: td ? 128 : 256),
                  curve: Curves.easeOutQuad,
                  child: MediaHandler().queuePlaying.isEmpty
                      ? Container()
                      : GestureDetector(
                          onPanStart: (details) => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => const SheetQueue(),
                          ),
                          child: SizedBox(
                            height: 64,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () => showSheet(
                                      scroll: true,
                                      func: MediaHandler().now.layer,
                                      param: null,
                                    ),
                                    child: MediaHandler().now.image(padding: EdgeInsets.zero) ?? Container(),
                                  ),
                                ),
                                Expanded(
                                  child: ValueListenableBuilder<PageController>(
                                    valueListenable: controller,
                                    builder: (context, controllerSnapshot, widget) {
                                      return PageView(
                                        key: Key(controllerSnapshot.hashCode.toString()),
                                        controller: controllerSnapshot,
                                        onPageChanged: (int newP) => MediaHandler().skipTo(newP),
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          for (int i = 0; i < MediaHandler().queuePlaying.length; i++)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                MediaHandler().now.title,
                                                style: TextStyle(
                                                  color: Theme.of(context).appBarTheme.foregroundColor,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: TopIcon(top: false),
                                ),
                              ],
                            ),
                          ),
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
