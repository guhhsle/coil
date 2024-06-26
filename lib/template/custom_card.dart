import 'package:flutter/material.dart';
import 'functions.dart';
import 'layer.dart';

class CustomCard extends StatelessWidget {
  final Setting setting;
  final EdgeInsets margin;

  const CustomCard(
    this.setting, {
    super.key,
    this.margin = const EdgeInsets.symmetric(
      vertical: 16,
      horizontal: 8,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 6,
        shadowColor: Theme.of(context).colorScheme.primary,
        margin: margin,
        color: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => setting.onTap(context),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      t(setting.title),
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: setting.trailing == ''
                      ? Icon(
                          setting.icon,
                          color: Theme.of(context).colorScheme.surface,
                        )
                      : Text(
                          t(setting.trailing),
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
