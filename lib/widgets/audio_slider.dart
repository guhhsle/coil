import 'package:flutter/material.dart';
import '../threads/main_thread.dart';
import '../audio/handler.dart';

class AudioSlider extends StatelessWidget {
  const AudioSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: MediaHandler().position,
      builder: (context, position, child) {
        return SizedBox(
          height: 24,
          child: Slider(
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary,
            secondaryActiveColor: Theme.of(context).colorScheme.primary,
            value: position.toDouble(),
            min: 0,
            onChanged: (d) => MainThread.callFn({'seek': d.toInt()}),
            max: MediaHandler().duration.value.toDouble(),
          ),
        );
      },
    );
  }
}
