import '../data.dart';
import '../functions/prefs.dart';
import 'handler.dart';

extension HandlerRemember on Handler {
  void rememberStream() {
    Handler().player.progressStateStream.listen((event) {
      int position = event.position;

      if (position / 60 >= pf['rememberThreshold'] && position % 5 == 0) {
        List<String> urls = pf['rememberURLs'] as List<String>;
        if (!urls.contains(queuePlaying[current.value].id)) {
          if (urls.length > pf['rememberLimit']) {
            urls.removeLast();
            pf['rememberTimes'].removeLast;
          }
          urls.insert(0, queuePlaying[current.value].id);
          pf['rememberTimes'].insert(0, '0');
          setPref('rememberURLs', urls);
        } else {
          pf['rememberTimes'][urls.indexOf(queuePlaying[current.value].id)] = '$position';
        }
        setPref('rememberTimes', pf['rememberTimes']);
      }
    });
  }

  int rememberedPosition(String url) {
    if (!pf['rememberURLs'].contains(url)) return 0;
    int i = pf['rememberURLs'].indexOf(url);
    return int.tryParse(pf['rememberTimes'][i]) ?? 0;
  }
}
