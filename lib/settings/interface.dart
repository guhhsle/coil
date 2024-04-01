import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../audio/handler.dart';
import '../data.dart';
import '../functions/other.dart';
import '../functions/prefs.dart';
import '../layer.dart';

Future<Layer> interfaceSet(dynamic non) async => Layer(
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
          Handler().refreshQueue.value = !Handler().refreshQueue.value;
        },
      ),
      list: [
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
            func: (non) async => Layer(
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
                    (c) {},
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

Future<Layer> themeMap(dynamic p) async {
  p is bool;
  var dispatcher = SchedulerBinding.instance.platformDispatcher;
  bool light = dispatcher.platformBrightness == Brightness.light;
  Layer layer = Layer(
      action: Setting(
        light ? pf[p ? 'primary' : 'background'] : pf[p ? 'primaryDark' : 'backgroundDark'],
        p ? Icons.colorize_rounded : Icons.tonality_rounded,
        '',
        (c) => fetchColor(p, light),
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
          light ? (p ? 'primary' : 'background') : (p ? 'primaryDark' : 'backgroundDark'),
          name,
          refresh: true,
        ),
        iconColor: colors.values.elementAt(i),
      ),
    );
  }
  return layer;
}

void fetchColor(bool p, bool light) {
  Clipboard.getData(Clipboard.kTextPlain).then((value) {
    if (value == null || value.text == null || int.tryParse('0xFF${value.text!.replaceAll('#', '')}') == null) {
      showSnack('Clipboard HEX', false);
    } else {
      setPref(
        light ? (p ? 'primary' : 'background') : (p ? 'primaryDark' : 'backgroundDark'),
        value.text!.replaceAll('#', ''),
        refresh: true,
      );
    }
  });
}
