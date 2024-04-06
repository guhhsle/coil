import 'package:audio_service/audio_service.dart';
import 'package:coil/audio/handler.dart';
import 'package:coil/audio/queue.dart';
import 'package:coil/audio/remember.dart';

extension StreamHandler on MediaHandler {
  void initStreams() {
    position.sink.add(0);
    playing.sink.add(false);
    duration.sink.add(1000);
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

    position.stream.listen((event) {
      if (queuePlaying.isNotEmpty) {
        lastPosition = event;
        checkToRemember(event);
        playbackState.add(playbackState.value.copyWith(
          updatePosition: Duration(seconds: event),
          bufferedPosition: Duration(seconds: event + 1),
        ));
      }
    });

    duration.stream.listen((event) {
      if (queuePlaying.isNotEmpty) {
        lastDuration = event;
        queue.add(queuePlaying);
        mediaItem.add(
          queuePlaying[current.value].copyWith(
            duration: Duration(seconds: event),
          ),
        );
      }
    });

    playing.stream.listen((event) {
      lastPlaying = event;
      playbackState.add(playbackState.value.copyWith(
        playing: event,
        controls: [
          MediaControl.skipToPrevious,
          event ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
      ));
    });

    processing.stream.listen((event) {
      if (event == 'completed') {
        bool isLast = current.value == queuePlaying.length - 1;
        skipTo({
          LoopMode.off: current.value + 1,
          LoopMode.one: current.value,
          LoopMode.all: isLast ? 0 : current.value + 1,
        }[loop]!);
      }
    });
  }
}
