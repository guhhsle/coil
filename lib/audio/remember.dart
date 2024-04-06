import '../data.dart';
import '../functions/prefs.dart';
import 'handler.dart';

extension HandlerRemember on MediaHandler {
  void checkToRemember(int position) {
    if (position / 60 >= pf['rememberThreshold'] && position % 5 == 0) {
      List<String> urls = pf['rememberURLs'] as List<String>;
      if (!urls.contains(now.id)) {
        if (urls.length > pf['rememberLimit']) {
          urls.removeLast();
          pf['rememberTimes'].removeLast;
        }
        urls.insert(0, now.id);
        pf['rememberTimes'].insert(0, '0');
        setPref('rememberURLs', urls);
      } else {
        pf['rememberTimes'][urls.indexOf(now.id)] = '$position';
      }
      setPref('rememberTimes', pf['rememberTimes']);
    }
  }

  int rememberedPosition(String id) {
    int i = pf['rememberURLs'].indexOf(id);
    if (i < 0) return 0;
    return int.tryParse(pf['rememberTimes'][i]) ?? 0;
  }
}
