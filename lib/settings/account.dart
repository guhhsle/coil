import 'package:flutter/material.dart';

import '../data.dart';
import '../functions/prefs.dart';
import '../http/export.dart';
import '../layer.dart';
import '../other/countries.dart';
import '../pages/page_log.dart';

Future<Layer> accountSet(dynamic non) async => Layer(
      action: Setting(
        'Configure',
        Icons.person_rounded,
        '',
        (c) => Navigator.of(c).push(
          MaterialPageRoute(
            builder: (context) => const PageLog(),
          ),
        ),
      ),
      list: [
        Setting(
          'Export',
          Icons.settings_backup_restore_rounded,
          '',
          (c) => showSheet(
            hidePrev: c,
            func: (non) async => Layer(
              action: Setting(
                'Export type',
                Icons.settings_backup_restore_rounded,
                '',
                (c) {},
              ),
              list: [
                Setting(
                  'File per list',
                  Icons.folder_outlined,
                  '',
                  (c) async {
                    Navigator.of(c).pop();
                    await exportUser(false);
                  },
                ),
                Setting(
                  'One file',
                  Icons.description_rounded,
                  '',
                  (c) async {
                    Navigator.of(c).pop();
                    await exportUser(true);
                  },
                ),
              ],
            ),
          ),
        ),
        Setting(
          'Country',
          Icons.outlined_flag_rounded,
          pf['location'],
          (c) => showSheet(
            hidePrev: c,
            scroll: true,
            func: (non) async => Layer(
              action: Setting(
                'Country',
                Icons.outlined_flag_rounded,
                '',
                (c) {},
              ),
              list: [
                ...countries.entries
                    .map(
                      (e) => Setting(
                        e.value,
                        Icons.language_rounded,
                        '',
                        (c) {
                          Navigator.of(c).pop();
                          setPref('location', e.value);
                        },
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ),
      ],
    );
