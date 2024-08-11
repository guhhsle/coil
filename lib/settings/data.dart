import 'package:flutter/material.dart';
import '../data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/prefs.dart';

Future<Layer> dataSet(dynamic non) async => Layer(
      action: Setting(
        'Quality',
        Icons.cloud_rounded,
        pf['bitrate'],
        (c) async {
          int? input = int.tryParse(await getInput(pf['bitrate'], 'Bitrate'));
          if (input == null) {
            showSnack('Invalid', false);
          } else {
            setPref('bitrate', input);
          }
        },
      ),
      list: [
        Setting(
          'Thumbnails',
          Icons.image_rounded,
          '${pf['thumbnails']}',
          (c) => revPref('thumbnails', refresh: true),
        ),
        Setting(
          'Recommend less popular',
          Icons.track_changes_rounded,
          '${pf['indie']}',
          (c) => revPref('indie'),
        ),
        Setting(
          'Recommend timeout (s)',
          Icons.track_changes_rounded,
          '${pf['timeLimit']}',
          (c) async {
            int? input = int.tryParse(await getInput(
              pf['timeLimit'],
              'Recommend timeout',
            ));
            if (input == null) {
              showSnack('Invalid', false);
            } else {
              setPref('timeLimit', input);
            }
          },
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
                for (int i = 0; i < pf['searchOrder'].length; i++)
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
                  ),
              ],
            ),
          ),
        ),
      ],
    );
