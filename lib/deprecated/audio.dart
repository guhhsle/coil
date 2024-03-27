/*
Duration currentDuration = Duration.zero;

class MyAudioHandler extends BaseAudioHandler {
  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
    player.createPositionStream().listen((position) {
      checkToRemember(currentDuration, position);
      int raz = ((player.duration ?? Duration.zero) - position).inMilliseconds;
      if (raz < 1000 && raz > 0) {
        skipTo(
          {
            LoopMode.off: current.value + 1,
            LoopMode.one: current.value,
            LoopMode.all: current.value == queuePlaying.length - 1 ? 0 : current.value + 1,
          }[loop]!,
        );
      }
    });
    /*
    OpenAsDefault.getFileIntent.then((value) {
      if (value != null) {
        load([
          MediaItem(
            title: path.basename(value.path).replaceAll('.m4a', '').replaceAll('.mp3', ''),
            artist: '',
            id: value.path,
            extras: {'url': value.path, 'offline': true},
          )
        ]);
        skipTo(0);
      }
    });
	*/
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await player.setAudioSource(ConcatenatingAudioSource(children: []));
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    player.playbackEventStream.listen((PlaybackEvent event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[player.processingState]!,
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> skipToNext() => skipTo(current.value + 1);

  @override
  Future<void> skipToPrevious() async {
    if (player.position.inSeconds < 10) {
      await skipTo(current.value - 1);
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    queuePlaying.clear();
    current.value = 0;
    player.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  void _listenForDurationChanges() {
    player.durationStream.listen((duration) {
      currentDuration = duration ?? Duration.zero;
      var index = player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (player.shuffleModeEnabled) {
        index = player.shuffleIndices!.indexOf(index);
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (player.shuffleModeEnabled) {
        index = player.shuffleIndices!.indexOf(index);
      }
      mediaItem.add(playlist[index]);
      controller.value = PageController(initialPage: index);
    });
  }

  void _listenForSequenceStateChanges() {
    player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }
}
*/

//
