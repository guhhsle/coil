import 'package:coil/audio/float.dart';
import 'package:coil/settings/account.dart';
import 'package:coil/settings/data.dart';
import 'package:coil/settings/home.dart';
import 'package:coil/settings/interface.dart';
import 'package:coil/settings/more.dart';
import 'package:flutter/material.dart';

import '../audio/top_icon.dart';
import '../data.dart';
import '../layer.dart';
import '../widgets/body.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  PageSettingsState createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings> {
  Map<String, Future<Layer> Function(dynamic)> map = {
    'More': moreSet,
    'Account': accountSet,
    'Data': dataSet,
    'Interface': interfaceSet,
    'Home': homeSet,
    'Primary': themeMap,
    'Background': themeMap,
  };

  Map<String, IconData> iconMap = {
    'More': Icons.segment_rounded,
    'Account': Icons.person_rounded,
    'Data': Icons.cloud_rounded,
    'Interface': Icons.toggle_on,
    'Home': Icons.door_front_door_rounded,
    'Primary': Icons.colorize_rounded,
    'Background': Icons.colorize_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const Float(),
      appBar: AppBar(
        title: Text(l['Settings']),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: TopIcon(),
          ),
        ],
      ),
      body: Body(
        child: ListView.builder(
          physics: scrollPhysics,
          padding: const EdgeInsets.only(top: 16, bottom: 32),
          itemCount: map.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(l[map.keys.elementAt(index)]!),
            leading: Icon(iconMap.values.elementAt(index)),
            onTap: () => showSheet(
              func: map.values.elementAt(index),
              param: index == 5,
              scroll: index > 4,
            ),
          ),
        ),
      ),
    );
  }
}
