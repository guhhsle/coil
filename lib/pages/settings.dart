import 'package:flutter/material.dart';
import '../audio/float.dart';
import '../settings/account.dart';
import '../settings/data.dart';
import '../settings/interface.dart';
import '../settings/more.dart';
import '../audio/top_icon.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/theme.dart';
import '../widgets/body.dart';

class PageSettings extends StatelessWidget {
  PageSettings({Key? key}) : super(key: key);

  final Map<String, Future<Layer> Function(dynamic)> map = {
    'More': moreSet,
    'Account': accountSet,
    'Data': dataSet,
    'Interface': interfaceSet,
    'Primary': themeMap,
    'Background': themeMap,
  };

  final Map<String, IconData> iconMap = {
    'More': Icons.segment_rounded,
    'Account': Icons.person_rounded,
    'Data': Icons.cloud_rounded,
    'Interface': Icons.toggle_on,
    'Primary': Icons.colorize_rounded,
    'Background': Icons.colorize_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const Float(),
      appBar: AppBar(
        title: Text(t('Settings')),
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
              param: index == 4,
              scroll: index > 3,
            ),
          ),
        ),
      ),
    );
  }
}
