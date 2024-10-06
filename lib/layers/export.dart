import 'package:flutter/material.dart';

import '../functions/export.dart';
import '../template/layer.dart';
import '../template/tile.dart';

class ExportCache extends Layer {
  @override
  void construct() {
    action = Tile('Select export type', Icons.settings_backup_restore_rounded);
    list = [
      Tile('Cache', Icons.cached_rounded, '', exportCache),
      Tile('File per list (Standard)', Icons.folder_outlined, '', () {
        exportUser(false);
      }),
      Tile('One file (Standard)', Icons.description_rounded, '', () {
        exportUser(true);
      }),
    ];
  }
}
