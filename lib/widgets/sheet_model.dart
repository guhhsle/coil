import 'package:flutter/material.dart';

import '../data.dart';
import '../layer.dart';
import 'custom_card.dart';

class SheetModel extends StatefulWidget {
  final Future<Layer> Function(dynamic) func;
  final dynamic param;
  const SheetModel({
    super.key,
    required this.func,
    required this.param,
  });

  @override
  State<SheetModel> createState() => _SheetModelState();
}

class _SheetModelState extends State<SheetModel> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.background.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder(
          valueListenable: refreshLay,
          builder: (context, non, child) {
            return FutureBuilder(
              future: widget.func.call(widget.func),
              builder: (context, snap) {
                if (!snap.hasData) return Container();
                Layer layer = snap.data!;
                List<Setting> list = layer.list;
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Row(
                      children: [
                        layer.leading == null ? Container() : layer.leading!(context),
                        Expanded(
                          child: CustomCard(layer.action),
                        )
                      ],
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, i) => list[i].toTile(context),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
