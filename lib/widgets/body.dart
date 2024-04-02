import 'package:flutter/material.dart';
import '../audio/handler.dart';
import '../data.dart';
import 'bottom_player.dart';

class Body extends StatelessWidget {
  final Widget child;

  const Body({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Handler().refreshQueue,
      builder: (context, none, non) {
        bool dock = pf['player'] == 'Dock';
        return Column(
          children: [
            BottomPlayer(show: pf['player'] == 'Top dock'),
            Expanded(
              child: Card(
                color: Theme.of(context).colorScheme.background,
                margin: EdgeInsets.symmetric(
                  horizontal: Handler().queuePlaying.isEmpty || !dock ? 0 : 2,
                ),
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(20),
                    bottom: Radius.circular(dock ? 20 : 0),
                  ),
                ),
                child: child,
              ),
            ),
            BottomPlayer(show: dock),
          ],
        );
      },
    );
  }
}
