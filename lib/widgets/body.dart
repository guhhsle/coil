import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/audio.dart';
import 'bottom_player.dart';

class Body extends StatelessWidget {
  final Widget child;

  const Body({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshQueue,
      builder: (context, snapIndex, widget) {
        return ValueListenableBuilder(
          valueListenable: showTopDock,
          builder: (context, data, ch) {
            bool dock = pf['player'] == 'Dock';
            bool topDock = pf['player'] == 'Top dock' && data;
            return Stack(
              children: [
                dock || topDock
                    ? Align(
                        alignment: dock ? Alignment.bottomCenter : Alignment.topCenter,
                        child: const BottomPlayer(),
                      )
                    : Container(),
                StreamBuilder(
                  stream: stateStream,
                  builder: (context, snapshot) {
                    int q = queuePlaying.isEmpty || !dock ? 0 : 1;
                    int p = queuePlaying.isEmpty || !topDock ? 0 : 1;
                    return AnimatedPadding(
                      curve: Curves.easeOutQuad,
                      duration: Duration(milliseconds: topDock ? 128 : 256),
                      padding: EdgeInsets.only(top: p * 64, bottom: q * 64, left: q * 2, right: q * 2),
                      child: Card(
                        color: Theme.of(context).colorScheme.background,
                        margin: EdgeInsets.zero,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: const Radius.circular(20),
                            bottom: Radius.circular(dock ? 20 : 0),
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
