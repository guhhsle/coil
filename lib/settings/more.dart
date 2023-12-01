import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';
import '../log.dart';
import '../other/countries.dart';
import '../other/license.dart';
import '../other/other.dart';
import '../services/audio.dart';

List<Setting> moreSet() => [
      Setting(
        'Versions',
        Icons.segment_rounded,
        '',
        (c) => singleChildSheet(
          title: 'Versions',
          icon: Icons.timeline_rounded,
          child: Text(versions),
          context: c,
        ),
      ),
      Setting(
        'License',
        Icons.format_align_center,
        'GPL3',
        (c) => singleChildSheet(
          title: 'GPL3',
          context: c,
          icon: Icons.format_align_center_rounded,
          child: Text(license),
        ),
      ),
      Setting(
        'Language',
        Icons.language_rounded,
        locales[pf['locale']]!,
        (c) => showSheet(
          scroll: true,
          hidePrev: c,
          list: (context) => [
            Setting(
              'Language',
              Icons.language_rounded,
              '',
              (c) {},
            ),
            ...locales.entries
                .map((e) => Setting(
                      e.value,
                      Icons.language_rounded,
                      '',
                      (c) => setPref('locale', e.key, refresh: true),
                    ))
                .toList(),
          ],
        ),
      ),
      Setting('Music folder', Icons.folder_outlined, 'pf//musicFolder', (c) {}),
      Setting(
        'Volume',
        Icons.graphic_eq_rounded,
        'pf//volume',
        (c) => showSheet(
          scroll: true,
          hidePrev: c,
          list: (context) => [
            Setting('pf//volume', Icons.graphic_eq_rounded, '', (c) {}),
            for (int i = 100; i >= 0; i -= 5)
              Setting(
                '$i %',
                Icons.graphic_eq_rounded,
                '',
                (c) {
                  setPref('volume', i);
                  setVolume();
                },
              ),
          ],
        ),
      ),
      Setting(
        'Remember threshold',
        Icons.timelapse_rounded,
        'pf//rememberThreshold',
        (c) => showSheet(
          scroll: true,
          hidePrev: c,
          list: (context) => [
            Setting('pf//rememberThreshold', Icons.timelapse_rounded, '', (c) {}),
            for (int i = 0; i < 65; i += 5)
              Setting(
                '$i min',
                Icons.timelapse_rounded,
                '',
                (c) => setPref('rememberThreshold', i),
              ),
          ],
        ),
      ),
    ];
