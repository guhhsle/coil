import 'package:flutter/material.dart';
import '../template/locale.dart';
import '../threads/main_thread.dart';
import '../data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/prefs.dart';

Future<Layer> otherSet(dynamic non) async => await moreSet(non)
  ..list.addAll([
    Setting(
      'Music folder',
      Icons.folder_outlined,
      pf['musicFolder'],
      (c) async {
        setPref(
            'musicFolder', await getInput(pf['musicFolder'], 'Folder link'));
      },
    ),
    Setting(
      'Volume',
      Icons.graphic_eq_rounded,
      '${pf['volume']}',
      (c) async {
        int? input = int.tryParse(await getInput(pf['volume'], 'Volume'));
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
        int? input = int.tryParse(await getInput(
          pf['rememberThreshold'],
          'Remember threshold',
        ));
        if (input == null || (input < 0)) {
          showSnack('Invalid', false);
        } else {
          setPref('rememberThreshold', input);
        }
      },
    ),
  ]);
