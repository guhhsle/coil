import 'package:coil/functions.dart';
import 'package:coil/settings/account.dart';
import 'package:coil/settings/data.dart';
import 'package:coil/settings/home.dart';
import 'package:coil/settings/interface.dart';
import 'package:coil/settings/more.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../other/other.dart';
import '../services/audio.dart';
import '../widgets/body.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  PageSettingsState createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings> {
  Map<String, List<Setting>> map = {
    'More': moreSet(),
    'Account': accountSet(),
    'Data': dataSet(),
    'Interface': interfaceSet(),
    'Home': homeSet(),
    'Primary': themeMap(true),
    'Background': themeMap(false),
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
            leading: Icon(
              map.values.elementAt(index).first.icon,
            ),
            onTap: () => showSheet(
              list: (context) => map.values.elementAt(index),
              scroll: index > 4,
            ),
          ),
        ),
      ),
    );
  }
}
