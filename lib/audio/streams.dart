import 'package:audio_service/audio_service.dart';
import 'package:coil/audio/handler.dart';
import 'package:coil/audio/queue.dart';
import 'package:coil/audio/remember.dart';

extension StreamHandler on MediaHandler {
  void initStreams() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.ready,
      playing: false,
      speed: 1,
      queueIndex: 0,
    ));

    position.addListener(() {
      if (queuePlaying.isNotEmpty) {
        int event = position.value;
        checkToRemember(event);
        playbackState.add(playbackState.value.copyWith(
          updatePosition: Duration(seconds: event),
          bufferedPosition: Duration(seconds: event + 1),
        ));
      }
    });

    duration.addListener(() {
      if (queuePlaying.isNotEmpty) {
        int event = duration.value;
        queue.add(queuePlaying);
        mediaItem.add(
          queuePlaying[index].copyWith(
            duration: Duration(seconds: event),
          ),
        );
      }
    });

    playing.addListener(() {
      bool event = playing.value;
      playbackState.add(playbackState.value.copyWith(
        playing: event,
        controls: [
          MediaControl.skipToPrevious,
          event ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
      ));
    });

    processing.addListener(() {
      String event = processing.value;
      if (event == 'completed') {
        bool isLast = index == queuePlaying.length - 1;
        skipTo(loop ? index : (isLast ? 0 : index + 1));
      }
    });
  }
}
