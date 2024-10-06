import '../../threads/main_thread.dart';
import '../../template/layer.dart';
import '../../template/tile.dart';
import '../../data.dart';

class OtherLayer extends Layer {
  @override
  void construct() {
    action = Tile.fromPref(Pref.musicFolder, onPrefInput: (loc) {
      Pref.musicFolder.set(loc);
    });
    list = [
      Tile.fromPref(Pref.locale),
      Tile.fromPref(Pref.volume, onPrefInput: (vol) {
        int volume = int.parse(vol).clamp(0, 100);
        Pref.volume.set(volume);
        MainThread.callFn({'volume': volume});
      }),
      Tile.fromPref(Pref.rememberThreshold, suffix: 'min', onPrefInput: (t) {
        Pref.rememberThreshold.set(int.parse(t));
      }),
    ];
  }
}
