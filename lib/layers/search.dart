import 'package:flutter/material.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../data.dart';

class SearchLayer extends Layer {
  List<String> get history => Pref.searchHistory.value.toList();
  void Function(String) onSelected;
  SearchLayer(this.onSelected);
  @override
  void construct() {
    scroll = true;
    action = Tile('Clear', Icons.clear_all_rounded, '', () {
      Pref.searchHistory.set(<String>[]);
      Navigator.of(context).pop();
    });
    list = history.map((query) {
      return Tile.complex(
        query,
        Icons.remove_rounded,
        '',
        () => onSelected(query),
        secondary: () => Pref.searchHistory.listRemove(query),
      );
    });
  }
}
