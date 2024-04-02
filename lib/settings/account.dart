import 'package:flutter/material.dart';
import 'auth.dart';
import '../data.dart';
import '../functions/export.dart';
import '../functions/prefs.dart';
import '../layer.dart';
import '../other/countries.dart';

Future<Layer> accountSet(dynamic non) async => Layer(
      action: Setting(
        'Configure',
        Icons.person_rounded,
        '',
        (c) => showSheet(func: authSet, hidePrev: c),
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
                'Select export type',
                Icons.settings_backup_restore_rounded,
                '',
                (c) {},
              ),
              list: [
                Setting(
                  'Cache',
                  Icons.cached_rounded,
                  '',
                  (c) => exportCache(),
                ),
                Setting(
                  'File per list (Standard)',
                  Icons.folder_outlined,
                  '',
                  (c) => exportUser(false),
                ),
                Setting(
                  'One file (Standard)',
                  Icons.description_rounded,
                  '',
                  (c) => exportUser(true),
                ),
              ],
            ),
          ),
        ),
        Setting(
          'Import Cache',
          Icons.settings_backup_restore_rounded,
          '',
          (c) => importCache(),
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
