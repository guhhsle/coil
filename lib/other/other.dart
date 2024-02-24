import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../functions.dart';
import '../widgets/custom_card.dart';

List<Setting> themeMap(bool p) {
  List<Setting> list = [
    Setting(
      p ? 'pf//primary' : 'pf//background',
      p ? Icons.colorize_rounded : Icons.tonality_rounded,
      '',
      (c) => fetchColor(p),
    ),
  ];
  for (int i = 0; i < colors.length; i++) {
    String name = colors.keys.toList()[i];
    list.add(
      Setting(
        name,
        iconsTheme[name]!,
        '',
        (c) => setPref(
          p ? 'primary' : 'background',
          name,
          refresh: true,
        ),
        iconColor: colors.values.elementAt(i),
      ),
    );
  }
  return list;
}

void fetchColor(bool p) {
  Clipboard.getData(Clipboard.kTextPlain).then((value) {
    if (value == null || value.text == null || int.tryParse('0xFF${value.text!.replaceAll('#', '')}') == null) {
      showSnack('Clipboard HEX', false);
    } else {
      setPref(
        p ? 'primary' : 'background',
        value.text,
        refresh: true,
      );
    }
  });
}

void showSnack(String text, bool good, {Function()? onTap}) {
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
    SnackBar(
      backgroundColor: good ? Colors.green.shade200 : Colors.red.shade200,
      content: Center(
        child: TextButton(
          onPressed: onTap ?? () {},
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> singleChildSheet({
  required String title,
  required IconData icon,
  required Widget child,
  required BuildContext context,
}) async {
  Navigator.of(context).pop();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.9,
          minChildSize: 0.2,
          builder: (_, controller) {
            return Card(
              margin: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.background.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    CustomCard(
                      Setting(
                        title,
                        icon,
                        '',
                        (c) {},
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 8,
                        ),
                        physics: scrollPhysics,
                        controller: controller,
                        child: Center(
                          child: DefaultTextStyle(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: pf['font'],
                              fontWeight: FontWeight.bold,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
