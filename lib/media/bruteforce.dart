import 'package:flutter/material.dart';
import 'media.dart';
import '../functions/other.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../audio/handler.dart';
import '../audio/queue.dart';
import '../media/http.dart';
import '../data.dart';

class BruteForceLayer extends Layer {
  Media media;
  List<String> pending = [];
  Map<String, String?> results = {};
  BruteForceLayer(this.media);

  Future bruteForceAll() async {
    results = {};
    pending = Pref.instanceHistory.value.toList();
    construct();
    notifyListeners();
    for (var instance in Pref.instanceHistory.value) {
      bruteForceInstance(instance).then((_) {});
    }
  }

  Future bruteForceInstance(String instance) async {
    try {
      media.audioUrl = null;
      final url = await media.forceLoad(instance: instance);
      debugPrint('$url');
      pending.remove(instance);
      results.addAll({instance: url});
    } catch (e) {
      debugPrint('$e');
    }
    construct();
    notifyListeners();
  }

  @override
  construct() {
    scroll = true;
    action = Tile('Bruteforcing', Icons.domain_rounded);
    trailing = [
      IconButton(
        onPressed: bruteForceAll,
        icon: const Icon(Icons.restart_alt_rounded),
      ),
    ];
    final done = results.entries.map((entry) {
      debugPrint('$entry');
      return Tile(
        formatInstanceName(entry.key),
        Icons.domain_rounded,
        entry.value != null,
        () async {
          Pref.instance.set(entry.key);
          final newUrl = await media.forceLoad(instance: entry.key);
          media.audioUrl = newUrl ?? entry.value;
          MediaHandler().load([media]);
          MediaHandler().skipTo(0);
        },
      );
    });
    final notDone = pending.map((instance) {
      debugPrint(instance);
      return Tile(formatInstanceName(instance), Icons.timer_rounded, 'Waiting');
    });
    list = [...done, ...notDone];
  }
}
