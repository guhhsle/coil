import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';
import 'custom_card.dart';

class SheetModel extends StatefulWidget {
  final List<Setting> list;

  const SheetModel({
    super.key,
    required this.list,
  });

  @override
  State<SheetModel> createState() => _SheetModelState();
}

class _SheetModelState extends State<SheetModel> {
  @override
  Widget build(BuildContext context) {
    List<Setting> list = widget.list;
    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.background.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            CustomCard(list.first),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: list.length - 1,
              itemBuilder: (context, index) {
                int i = index + 1;
                return ListTile(
                  leading: list[i].onHold == null ? Icon(list[i].icon, color: list[i].iconColor) : null,
                  title: Text(t(list[i].title)),
                  trailing: list[i].onHold != null
                      ? IconButton(
                          icon: Icon(list[i].icon),
                          onPressed: () {
                            list[i].onHold!(context);
                            setState(() {});
                          },
                        )
                      : Text(t(list[i].trailing)),
                  onTap: () {
                    list[i].onTap(context);
                    setState(() {});
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
