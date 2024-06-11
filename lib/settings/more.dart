import 'package:coil/threads/main_thread.dart';
import 'package:flutter/material.dart';
import '../countries.dart';
import '../data.dart';
import '../log.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/license.dart';
import '../template/prefs.dart';
import '../template/single_child.dart';

Future<Layer> moreSet(dynamic non) async => Layer(
      action: Setting(
        'Versions',
        Icons.segment_rounded,
        '',
        (c) => singleChildSheet(
          action: Setting(
            'Versions',
            Icons.timeline_rounded,
            '',
            (c) {},
          ),
          child: Text(versions),
        ),
      ),
      list: [
        Setting(
          'License',
          Icons.format_align_center,
          'GPL3',
          (c) => singleChildSheet(
            action: Setting(
              'GPL3',
              Icons.format_align_center_rounded,
              '',
              (c) {},
            ),
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
              MainThread.callFn({'volume': input});
              await setPref('volume', input);
            }
          },
        ),
        Setting(
          'Remember threshold',
          Icons.timelapse_rounded,
          '${pf['rememberThreshold']} min',
          (c) async {
            int? input =
                int.tryParse(await getInput('${pf['rememberThreshold']}'));
            if (input == null || (input < 0)) {
              showSnack('Invalid', false);
            } else {
              setPref('rememberThreshold', input);
            }
          },
        ),
      ],
    );
