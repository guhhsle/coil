import 'package:flutter/material.dart';
import 'auth.dart';
import '../../functions/export.dart';
import '../../template/layer.dart';
import '../../template/tile.dart';
import '../../countries.dart';
import '../../data.dart';
import '../export.dart';

class AccountLayer extends Layer {
  @override
  void construct() {
    action = Tile('Configure', Icons.person_rounded, '', () {
      Navigator.of(context).pop();
      AuthLayer().show();
    });
    list = [
      Tile('Export', Icons.settings_backup_restore_rounded, '', () {
        Navigator.of(context).pop();
        ExportCache().show();
      }),
      Tile('Import Cache', Icons.settings_backup_restore_rounded, '', () {
        importCache();
      }),
      Tile.fromPref(Pref.location, onTap: () {
        Navigator.of(context).pop();
        CountryLayer().show();
      }),
      Tile.fromPref(Pref.debug),
    ];
  }
}

class CountryLayer extends Layer {
  @override
  void construct() {
    action = Tile('Country', Icons.outlined_flag_rounded);
    list = countries.entries.map((e) {
      return Tile(e.value, Icons.language_rounded, '', () {
        Navigator.of(context).pop();
        Pref.location.set(e.value);
      });
    });
  }
}