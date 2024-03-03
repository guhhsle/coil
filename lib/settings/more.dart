import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';
import '../layer.dart';
import '../log.dart';
import '../other/countries.dart';
import '../other/license.dart';
import '../other/other.dart';
import '../services/audio.dart';

Layer moreSet(dynamic non) => Layer(
      action: Setting(
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
      list: [
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
            func: (non) => Layer(
              action: Setting(
                'Language',
                Icons.language_rounded,
                '',
                (c) {},
              ),
              list: [
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
        ),
        Setting('Music folder', Icons.folder_outlined, pf['musicFolder'], (c) {}),
        Setting(
          'Volume',
          Icons.graphic_eq_rounded,
          '${pf['volume']}',
          (c) => showSheet(
            scroll: true,
            hidePrev: c,
            func: (non) => Layer(
              action: Setting('${pf['volume']}', Icons.graphic_eq_rounded, '', (c) {}),
              list: [
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
        ),
        Setting(
          'Remember threshold',
          Icons.timelapse_rounded,
          '${pf['rememberThreshold']} min',
          (c) => showSheet(
            scroll: true,
            hidePrev: c,
            func: (non) => Layer(
              action: Setting('${pf['rememberThreshold']} min', Icons.timelapse_rounded, '', (c) {}),
              list: [
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
        ),
      ],
    );
