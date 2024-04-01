import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/other.dart';
import '../functions/prefs.dart';
import '../layer.dart';

Future<Layer> dataSet(dynamic non) async => Layer(
      action: Setting(
        'Quality',
        Icons.cloud_rounded,
        '${pf['bitrate']}',
        (c) async {
          int? input = int.tryParse(await getInput('${pf['bitrate']}'));
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
            int? input = int.tryParse(await getInput('${pf['timeLimit']}'));
            if (input == null) {
              showSnack('Invalid', false);
            } else {
              setPref('timeLimit', input);
            }
          },
        ),
      ],
    );
