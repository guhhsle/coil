import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';

List<Setting> interfaceSet() => [
      Setting(
        'Player',
        Icons.toggle_on,
        'pf//player',
        (c) {
          nextPref(
            'player',
            ['Dock', 'Top', 'Top dock', 'Floating'],
            refresh: true,
          );
          refreshQueue.value = !refreshQueue.value;
        },
      ),
      Setting(
        'Reverse',
        Icons.low_priority_rounded,
        'pf//reverse',
        (c) => revPref('reverse', refresh: true),
      ),
      Setting(
        'Top',
        Icons.gradient_rounded,
        'pf//appbar',
        (c) => nextPref(
          'appbar',
          ['Black', 'Primary', 'Transparent'],
          refresh: true,
        ),
      ),
      Setting(
        'Artist in tile',
        Icons.person_rounded,
        'pf//artist',
        (c) => revPref('artist', refresh: true),
      ),
      Setting(
        'Search',
        Icons.fiber_manual_record_outlined,
        'Reorder',
        (c) => showSheet(
          hidePrev: c,
          list: (context) => [
            Setting(
              'Search',
              Icons.fiber_manual_record_outlined,
              '',
              (c) {},
            ),
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
                    refresh: true,
                  );
                },
                onHold: (c) {
                  if (i == 0) return;
                  List<String> l = pf['searchOrder'];
                  setPref(
                    'searchOrder',
                    l..insert(i - 1, l.removeAt(i)),
                    refresh: true,
                  );
                },
              ),
          ],
        ),
      ),
    ];
