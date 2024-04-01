import 'package:flutter/material.dart';
import '../functions/other.dart';

class CustomChip extends StatefulWidget {
  final void Function(bool value) onSelected;
  final bool selected;
  final String label;

  const CustomChip({
    Key? key,
    required this.onSelected,
    required this.selected,
    required this.label,
  }) : super(key: key);

  @override
  State<CustomChip> createState() => _CustomChipState();
}

class _CustomChipState extends State<CustomChip> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        selected: widget.selected,
        showCheckmark: false,
        onSelected: widget.onSelected,
        label: Text(
          t(widget.label),
          style: TextStyle(
            color: widget.selected ? Theme.of(context).colorScheme.background : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
