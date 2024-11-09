import 'package:flutter/material.dart';
import '../../template/layer.dart';
import '../../template/tile.dart';
import '../../data.dart';

class DataLayer extends Layer {
  @override
  void construct() {
    action = Tile.fromPref(Pref.bitrate, onPrefInput: (i) {
      Pref.bitrate.set(int.parse(i));
    });
    list = [
      Tile.fromPref(Pref.thumbnails),
      Tile.fromPref(Pref.indie),
      Tile.fromPref(Pref.timeLimit, onPrefInput: (i) {
        Pref.timeLimit.set(int.parse(i).clamp(0, 1000));
      }),
      Tile('Search', Icons.fiber_manual_record_outlined, 'Reorder', () {
        ReorderSearch().show();
      }),
      Tile.fromPref(Pref.alternative, onPrefInput: (i) {
        Pref.alternative.set(i);
      }),
      Tile.fromPref(Pref.maxPreload, onPrefInput: (i) {
        Pref.maxPreload.set(int.parse(i).clamp(0, 10));
      })
    ];
  }
}

class ReorderSearch extends Layer {
  @override
  void construct() {
    action = Tile('Search', Icons.fiber_manual_record_outlined);
    list = [
      for (int i = 0; i < Pref.searchOrder.value.length; i++)
        Tile(
          Pref.searchOrder.value[i],
          Icons.expand_less_rounded,
          '',
          () {
            if (i == 0) return;
            List<String> l = Pref.searchOrder.value;
            Pref.searchOrder.set(l..insert(i - 1, l.removeAt(i)));
          },
        ),
    ];
  }
}
