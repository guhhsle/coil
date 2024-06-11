import 'package:flutter/material.dart';
import '../audio/float.dart';
import '../audio/handler.dart';
import '../audio/top_icon.dart';
import '../data.dart';
import 'bottom_player.dart';

class Frame extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget? child;
  final bool automaticallyImplyLeading;

  const Frame({
    super.key,
    this.title = const SizedBox(),
    this.actions = const [],
    this.child,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const Float(),
      appBar: AppBar(
        title: title,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: [
          const TopIcon(),
          ...actions,
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: MediaHandler.refreshQueue,
        builder: (context, none, non) {
          bool dock = pf['player'] == 'Dock';
          return Column(
            children: [
              BottomPlayer(show: pf['player'] == 'Top dock'),
              Expanded(
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: EdgeInsets.symmetric(
                    horizontal:
                        MediaHandler().queuePlaying.isEmpty || !dock ? 0 : 2,
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
      ),
    );
  }
}
