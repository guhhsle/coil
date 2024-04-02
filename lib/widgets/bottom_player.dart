import 'package:flutter/material.dart';
import '../audio/queue.dart';
import '../data.dart';
import '../audio/handler.dart';
import '../audio/top_icon.dart';
import '../functions/sheets.dart';
import '../layer.dart';
import 'sheet_queue.dart';

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
          valueListenable: Handler().refreshQueue,
          builder: (context, non, none) {
            return ValueListenableBuilder(
              valueListenable: Handler().current,
              builder: (context, i, none) {
                return AnimatedContainer(
                  height: Handler().queuePlaying.isEmpty || (td && !showTop) ? 0 : 64,
                  key: const Key('cont'),
                  duration: Duration(milliseconds: td ? 128 : 256),
                  curve: Curves.easeOutQuad,
                  child: Handler().queuePlaying.isEmpty
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
                                      func: mediaToLayer,
                                      param: Handler().queuePlaying[i],
                                    ),
                                    child: Handler().queuePlaying[i].image(padding: EdgeInsets.zero) ?? Container(),
                                  ),
                                ),
                                Expanded(
                                  child: ValueListenableBuilder<PageController>(
                                    valueListenable: controller,
                                    builder: (context, controllerSnapshot, widget) {
                                      return PageView(
                                        key: Key(controllerSnapshot.hashCode.toString()),
                                        controller: controllerSnapshot,
                                        onPageChanged: (int newP) => Handler().skipTo(newP),
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          for (int i = 0; i < Handler().queuePlaying.length; i++)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                Handler().queuePlaying[i].title ?? '',
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
