import 'package:flutter/material.dart';
import '../functions/other.dart';
import '../data.dart';
import '../functions/prefs.dart';
import '../functions/single_child.dart';
import '../layer.dart';
import '../log.dart';
import '../other/countries.dart';
import '../other/license.dart';

Future<Layer> moreSet(dynamic non) async => Layer(
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
            func: (non) async => Layer(
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
        Setting(
          'Music folder',
          Icons.folder_outlined,
          pf['musicFolder'],
          (c) async {
            setPref('musicFolder', await getInput(pf['musicFolder']));
          },
        ),
        Setting(
          'Volume',
          Icons.graphic_eq_rounded,
          '${pf['volume']}',
          (c) async {
            int? input = int.tryParse(await getInput('${pf['volume']}'));
            if (input == null || (input > 100 || input < 0)) {
              showSnack('Invalid', false);
            } else {
              await setPref('volume', input);
              //Handler().setVolume();
            }
          },
        ),
        Setting(
          'Remember threshold',
          Icons.timelapse_rounded,
          '${pf['rememberThreshold']} min',
          (c) async {
            int? input = int.tryParse(await getInput('${pf['rememberThreshold']}'));
            if (input == null || (input < 0)) {
              showSnack('Invalid', false);
            } else {
              setPref('rememberThreshold', input);
            }
          },
        ),
      ],
    );
