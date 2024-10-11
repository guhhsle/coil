import 'handler.dart';
import '../data.dart';

extension HandlerRemember on MediaHandler {
  void checkToRemember(int position) {
    if (position / 60 >= Pref.rememberThreshold.value && position % 5 == 0) {
      List<String> urls = Pref.rememberURLs.value.toList();
      List<String> times = Pref.rememberTimes.value.toList();
      if (!urls.contains(current.id)) {
        if (urls.length > Pref.rememberLimit.value) {
          urls.removeLast();
          times.removeLast;
        }
        urls.insert(0, current.id);
        times.insert(0, '0');
        Pref.rememberURLs.set(urls);
      } else {
        times[urls.indexOf(current.id)] = '$position';
      }
      Pref.rememberTimes.set(times);
    }
  }

  int rememberedPosition(String id) {
    int i = Pref.rememberURLs.value.indexOf(id);
    if (i < 0) return 0;
    return int.tryParse(Pref.rememberTimes.value[i]) ?? 0;
  }
}
