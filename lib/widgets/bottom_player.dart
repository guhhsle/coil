import 'package:flutter/material.dart';
import 'sheet_queue.dart';
import '../template/prefs.dart';
import '../audio/top_icon.dart';
import '../audio/handler.dart';
import '../layers/media.dart';
import '../audio/queue.dart';
import '../data.dart';

class BottomPlayer extends StatelessWidget {
  final bool show;
  const BottomPlayer({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    if (!show) return Container();
    return ListenableBuilder(
      listenable:
          Listenable.merge([Preferences(), MediaHandler(), showTopDock]),
      builder: (context, non) {
        bool td = Pref.player.value == 'Top dock';
        return AnimatedContainer(
          height: MediaHandler().isEmpty || (td && !showTopDock.value) ? 0 : 64,
          key: const Key('cont'),
          duration: Duration(milliseconds: td ? 128 : 256),
          curve: Curves.easeOutQuad,
          child: Builder(
            builder: (context) {
              if (MediaHandler().isEmpty) return Container();
              return GestureDetector(
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
                          onTap: () {
                            MediaLayer(MediaHandler().current).show();
                          },
                          child: MediaHandler()
                                  .current
                                  .image(padding: EdgeInsets.zero) ??
                              Container(),
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          key: Key(MediaHandler().current.toString()),
                          controller: MediaHandler().bottomText,
                          onPageChanged: (int newP) =>
                              MediaHandler().skipTo(newP),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            for (int i = 0; i < MediaHandler().length; i++)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  MediaHandler().tracklist[i].title,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .foregroundColor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: TopIcon(top: false),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
