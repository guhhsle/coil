import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../functions/other.dart';
import '../functions/prefs.dart';
import '../layer.dart';

Layer interfaceSet(dynamic non) => Layer(
      action: Setting(
        'Player',
        Icons.toggle_on,
        pf['player'],
        (c) {
          nextPref(
            'player',
            ['Dock', 'Top', 'Top dock', 'Floating'],
            refresh: true,
          );
          refreshQueue.value = !refreshQueue.value;
        },
      ),
      list: [
        Setting(
          'Reverse',
          Icons.low_priority_rounded,
          '${pf['reverse']}',
          (c) => revPref('reverse'),
        ),
        Setting(
          'Top',
          Icons.gradient_rounded,
          pf['appbar'],
          (c) => nextPref(
            'appbar',
            ['Black', 'Primary', 'Transparent'],
            refresh: true,
          ),
        ),
        Setting(
          'Artist in tile',
          Icons.person_rounded,
          '${pf['artist']}',
          (c) => revPref('artist'),
        ),
        Setting(
          'Search',
          Icons.fiber_manual_record_outlined,
          'Reorder',
          (c) => showSheet(
            hidePrev: c,
            func: (non) => Layer(
              action: Setting(
                'Search',
                Icons.fiber_manual_record_outlined,
                '',
                (c) {},
              ),
              list: [
                for (int i = 0; i < 6; i++)
                  Setting(
                    pf['searchOrder'][i],
                    Icons.expand_less_rounded,
                    '',
                    (c) {
                      if (i == 0) return;
                      List<String> l = pf['searchOrder'];
                      setPref(
                        'searchOrder',
                        l..insert(i - 1, l.removeAt(i)),
                      );
                    },
                    secondary: (c) {
                      if (i == 0) return;
                      List<String> l = pf['searchOrder'];
                      setPref(
                        'searchOrder',
                        l..insert(i - 1, l.removeAt(i)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );

Layer themeMap(dynamic p) {
  p is bool;
  Layer layer = Layer(
      action: Setting(
        pf[p ? 'primary' : 'background'],
        p ? Icons.colorize_rounded : Icons.tonality_rounded,
        '',
        (c) => fetchColor(p),
      ),
      list: []);
  for (int i = 0; i < colors.length; i++) {
    String name = colors.keys.toList()[i];
    layer.list.add(
      Setting(
        name,
        iconsTheme[name]!,
        '',
        (c) => setPref(
          p ? 'primary' : 'background',
          name,
          refresh: true,
        ),
        iconColor: colors.values.elementAt(i),
      ),
    );
  }
  return layer;
}

void fetchColor(bool p) {
  Clipboard.getData(Clipboard.kTextPlain).then((value) {
    if (value == null || value.text == null || int.tryParse('0xFF${value.text!.replaceAll('#', '')}') == null) {
      showSnack('Clipboard HEX', false);
    } else {
      setPref(
        p ? 'primary' : 'background',
        value.text,
        refresh: true,
      );
    }
  });
}
