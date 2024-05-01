import 'package:flutter/material.dart';
import '../audio/handler.dart';
import '../data.dart';
import '../template/layer.dart';
import '../template/prefs.dart';

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
          MediaHandler().refresh();
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
          'Home',
          Icons.door_front_door_rounded,
          'Reorder',
          (c) => showSheet(
            hidePrev: c,
            func: (non) async => Layer(
              action: Setting(
                'Home',
                Icons.door_front_door_rounded,
                '',
                (c) {},
              ),
              list: [
                for (int i = 0; i < pf['homeOrder'].length; i++)
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
                  ),
              ],
            ),
          ),
        ),
        Setting(
          'Tags',
          Icons.label_rounded,
          pf['tags'],
          (c) => nextPref('tags', ['Hide', 'Top', 'Bottom'], refresh: true),
        ),
        Setting(
          'Sort',
          Icons.sort_rounded,
          pf['sortBy'],
          (c) => showSheet(
            func: (non) async => Layer(
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
        ),
      ],
    );
