import 'package:flutter/material.dart';
import '../functions/other.dart';

class CustomChip extends StatelessWidget {
  final void Function(bool value) onSelected;
  final bool selected, showCheckmark;
  final String label;

  const CustomChip({
    Key? key,
    required this.onSelected,
    required this.selected,
    required this.label,
    this.showCheckmark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        selected: selected,
        showCheckmark: showCheckmark,
        onSelected: onSelected,
        label: Text(
          t(label),
          style: TextStyle(
            color: selected ? Theme.of(context).colorScheme.background : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
