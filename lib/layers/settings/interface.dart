import 'package:flutter/material.dart';
import '../../template/layer.dart';
import '../../template/tile.dart';
import '../../data.dart';

class InterfaceLayer extends Layer {
  @override
  void construct() {
    action = Tile.fromPref(Pref.player);
    list = [
      Tile.fromPref(Pref.appbar),
      Tile.fromPref(Pref.artist),
      Tile('Home order', Icons.door_front_door_rounded, '', () {
        ReorderHome().show();
      }),
      Tile.fromPref(Pref.tags),
      Tile.fromPref(Pref.sortBy),
    ];
  }
}

class ReorderHome extends Layer {
  @override
  void construct() {
    action = Tile('Home', Icons.door_front_door_rounded);
    list = [
      for (int i = 0; i < Pref.homeOrder.value.length; i++)
        Tile(Pref.homeOrder.value[i], Icons.expand_less_rounded, '', () {
          if (i == 0) return;
          List<String> l = Pref.homeOrder.value;
          Pref.homeOrder.set(l..insert(i - 1, l.removeAt(i)));
        }),
    ];
  }
}
