import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../template/functions.dart';
import '../functions/other.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../data.dart';

class Instances extends Layer {
  final completer = Completer<String>();
  @override
  void construct() {
    action = Tile('Instances', Icons.domain_rounded, '', () {
      launchUrl(
        Uri.parse('https://github.com/TeamPiped/Piped/wiki/Instances'),
        mode: LaunchMode.externalApplication,
      );
    });
    list = Pref.instanceHistory.value.map<Tile>((instance) {
      return Tile.complex(
        instance,
        icon(instance),
        '',
        () {
          Navigator.of(context).pop();
          completer.complete(instance);
        },
        secondary: () => Pref.instanceHistory.set(
          Pref.instanceHistory.value..remove(instance),
        ),
      );
    });
    trailing = [
      IconButton(
        icon: const Icon(Icons.add_rounded),
        onPressed: () => getInput('', 'Instance link').then((link) {
          final instance = trimUrl(link);
          Pref.instanceHistory.set(Pref.instanceHistory.value..add(instance));
        }),
      ),
    ];
  }

  IconData icon(String instance) {
    if (instance == Pref.authInstance.value) return Icons.lock_rounded;
    if (instance == Pref.instance.value) return Icons.domain_rounded;
    return Icons.remove_rounded;
  }
}
