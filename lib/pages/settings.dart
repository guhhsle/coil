import 'package:coil/data.dart';
import 'package:flutter/material.dart';
import '../audio/float.dart';
import '../audio/top_icon.dart';
import '../template/functions.dart';
import '../widgets/body.dart';

class PageSettings extends StatelessWidget {
  const PageSettings({Key? key}) : super(key: key);

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
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: settings.length,
          itemBuilder: (context, i) => settings[i].toTile(context),
        ),
      ),
    );
  }
}
