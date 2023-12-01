import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';
import 'custom_card.dart';

class SheetScrollModel extends StatefulWidget {
  final List<Setting> list;
  const SheetScrollModel({
    super.key,
    required this.list,
  });

  @override
  SheetScrollModelState createState() => SheetScrollModelState();
}

class SheetScrollModelState extends State<SheetScrollModel> {
  @override
  Widget build(BuildContext context) {
    List<Setting> list = widget.list;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.45,
          maxChildSize: 0.75,
          minChildSize: 0.2,
          builder: (_, controller) => Card(
            margin: const EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.background.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  CustomCard(list.first),
                  Expanded(
                    child: Scrollbar(
                      controller: controller,
                      child: ListView.builder(
                        physics: scrollPhysics,
                        padding: const EdgeInsets.only(bottom: 8),
                        controller: controller,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
