import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';

List<Setting> dataSet() => [
      Setting(
        'Quality',
        Icons.cloud_rounded,
        'pf//bitrate',
        (c) => showSheet(
          hidePrev: c,
          list: (context) => [
            Setting('pf//bitrate', Icons.graphic_eq_rounded, '', (c) {}),
            for (int i = 180000; i >= 30000; i -= 30000)
              Setting(
                '$i',
                Icons.graphic_eq_rounded,
                '',
                (c) => setPref('bitrate', i),
              ),
          ],
        ),
      ),
      Setting(
        'List thumbnail',
        Icons.collections_rounded,
        'pf//thumbnails',
        (c) => revPref('thumbnails', refresh: true),
      ),
      Setting(
        'Song thumbnail',
        Icons.image_rounded,
        'pf//songThumbnails',
        (c) => revPref('songThumbnails', refresh: true),
      ),
      Setting(
        'Recommend less popular',
        Icons.track_changes_rounded,
        'pf//indie',
        (c) => revPref('indie'),
      ),
      Setting(
        'Recommend timeout (s)',
        Icons.track_changes_rounded,
        'pf//timeLimit',
        (c) => showSheet(
          scroll: true,
          hidePrev: c,
          list: (context) => [
            Setting('pf//timeLimit', Icons.track_changes_rounded, '', (c) {}),
            for (int i = 2; i < 22; i += 2)
              Setting(
                '$i s',
                Icons.track_changes_rounded,
                '',
                (c) => setPref('timeLimit', i),
              ),
          ],
        ),
      ),
    ];
