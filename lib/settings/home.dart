import 'package:coil/functions.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../layer.dart';

Layer homeSet(dynamic non) => Layer(
      action: Setting(
        'Home',
        Icons.door_front_door_rounded,
        'Reorder',
        (c) => showSheet(
            hidePrev: c,
            func: (non) => Layer(
                  action: Setting(
                    'Home',
                    Icons.door_front_door_rounded,
                    '',
                    (c) {},
                  ),
                  list: [
                    for (int i = 0; i < 5; i++)
                      Setting(
                        pf['homeOrder'][i],
                        Icons.expand_less_rounded,
                        '',
                        (c) {
                          if (i == 0) return;
                          List<String> l = pf['homeOrder'];
                          setPref(
                            'homeOrder',
                            l..insert(i - 1, l.removeAt(i)),
                            refresh: true,
                          );
                        },
                        onHold: (c) {
                          if (i == 0) return;
                          List<String> l = pf['homeOrder'];
                          setPref(
                            'homeOrder',
                            l..insert(i - 1, l.removeAt(i)),
                            refresh: true,
                          );
                        },
                      ),
                  ],
                )),
      ),
      list: [
        Setting(
          'Tags',
          Icons.label_rounded,
          pf['tags'],
          (c) => nextPref('tags', ['Hide', 'Top', 'Bottom'], refresh: true),
        ),
        Setting(
          'Grid',
          Icons.grid_3x3_rounded,
          '${pf['grid']}',
          (c) => setPref('grid', (pf['grid'] + 1) % 5, refresh: true),
        ),
        Setting(
          'Sort',
          Icons.sort_rounded,
          pf['sortBy'],
          (c) => showSheet(
            func: (non) => Layer(
              action: Setting(pf['sortBy'], Icons.sort_rounded, '', (c) {}),
              list: [
                for (String s in [
                  'Name',
                  'Name <',
                  'Length',
                  'Length <',
                  'Default',
                  'Default <',
                ])
                  Setting(
                    s,
                    Icons.sort_rounded,
                    '',
                    (c) => setPref('sortBy', s, refresh: true),
                  )
              ],
            ),
          ),
        )
      ],
    );
