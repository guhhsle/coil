import 'package:coil/data.dart';
import 'package:flutter/material.dart';
import '../template/functions.dart';
import '../widgets/frame.dart';

class PageSettings extends StatelessWidget {
  const PageSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Frame(
      title: Text(t('Settings')),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: settings.length,
        itemBuilder: (context, i) => settings[i].toTile(context),
      ),
    );
  }
}
