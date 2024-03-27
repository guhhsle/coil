import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

import 'handler.dart';

class AudioSlider extends StatelessWidget {
  const AudioSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgressState>(
      stream: Handler().player.progressStateStream,
      builder: (context, position) {
        if (!position.hasData) return Container();
        return SizedBox(
          height: 24,
          child: Slider(
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary,
            secondaryActiveColor: Theme.of(context).colorScheme.primary,
            value: (position.data?.position ?? 999).toDouble(),
            min: 0,
            onChanged: (d) => Handler().player.seek(d.toInt()),
            max: (position.data?.duration ?? 999).toDouble(),
          ),
        );
      },
    );
  }
}
