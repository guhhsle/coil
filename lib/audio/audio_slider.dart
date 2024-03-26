import 'package:flutter/material.dart';

import '../functions/audio.dart';

class AudioSlider extends StatelessWidget {
  const AudioSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, position) {
        if (!position.hasData) return Container();
        Duration max = player.duration ?? const Duration(hours: 1);
        //Duration pos = position.data!;
        return SizedBox(
          height: 24,
          child: Slider(
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary,
            secondaryActiveColor: Theme.of(context).colorScheme.primary,
            value: position.data!.inSeconds.toDouble(),
            min: 0,
            onChanged: (d) => player.seek(
              Duration(seconds: d.toInt()),
            ),
            max: max.inSeconds.toDouble(),
          ),
        );
      },
    );
  }
}
