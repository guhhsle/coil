import 'dart:io';

import 'package:coil/settings/auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../functions/other.dart';
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
                'Export type',
                Icons.settings_backup_restore_rounded,
                '',
                (c) {},
              ),
              list: [
                Setting(
                  'Cache',
                  Icons.cached_rounded,
                  '',
                  (c) async {
                    File file = File('${pf['appDirectory']}/playlists.json');
                    await writeFile('playlists.json', await file.readAsString());
                    file = File('${pf['appDirectory']}/100raw.json');
                    await writeFile('100raw.json', await file.readAsString());
                    file = File('${pf['appDirectory']}/Bookmarks.json');
                    await writeFile('Bookmarks.json', await file.readAsString());
                    for (Map userPlaylist in userPlaylists.value) {
                      String name = '${formatUrl(userPlaylist['id'])}.json';
                      file = File('${pf['appDirectory']}/$name');
                      await writeFile(name, await file.readAsString());
                    }
                  },
                ),
                Setting(
                  'File per list (Standard)',
                  Icons.folder_outlined,
                  '',
                  (c) async {
                    Navigator.of(c).pop();
                    await exportUser(false);
                  },
                ),
                Setting(
                  'One file (Standard)',
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
          'Import Cache',
          Icons.settings_backup_restore_rounded,
          '',
          (c) async {
            try {
              FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
              List<File> files = result!.paths.map((path) => File(path!)).toList();
              for (File backedFile in files) {
                File cacheFile = File('${pf['appDirectory']}/${basename(backedFile.path)}');
                cacheFile.writeAsBytes(await backedFile.readAsBytes());
              }
            } catch (e) {
              showSnack('$e', false);
            }
          },
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
