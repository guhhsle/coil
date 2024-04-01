/*
import 'dart:async';
import 'dart:convert';

import 'package:coil/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../functions/other.dart';
import '../functions/prefs.dart';
import '../widgets/body.dart';
import '../widgets/user_playlists.dart';

class PageLog extends StatefulWidget {
  const PageLog({Key? key}) : super(key: key);

  @override
  State<PageLog> createState() => _PageLogState();
}

final List<String> initials = [
  'instance',
  'authInstance',
  'username',
  'password',
];

class _PageLogState extends State<PageLog> {
  List<TextEditingController> controllers = [
    for (int i = 0; i < 4; i++) TextEditingController(text: pf[initials[i]]),
  ];

  Future<bool> login(
    String username,
    String password,
    bool exists,
  ) async {
    setPref('token', '');
    Response result = await post(
      Uri.https(pf['authInstance'], exists ? 'login' : 'register'),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    if (jsonDecode(result.body)['token'] != null) {
      setPref('token', jsonDecode(result.body)['token']);
      setPref('username', username);
      setPref('password', password);
      unawaited(fetchUserPlaylists(true));
      return true;
    } else {
      showSnack(jsonDecode(result.body)['error'], false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(l['Account']!),
        ),
        actions: [
          pf['instanceHistory'].isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.history_rounded),
                  onPressed: () async {
                    String instance = await instanceHistory();
                    Clipboard.setData(ClipboardData(text: instance));
                    showSnack('Clipboard', true);
                  },
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: l['Instances'],
              onPressed: () async => await launchUrl(
                Uri.parse('https://github.com/TeamPiped/Piped/wiki/Instances'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.domain_rounded),
            ),
          ),
        ],
      ),
      body: Body(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          child: Center(
            child: AutofillGroup(
              child: ListView(
                physics: scrollPhysics,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.url],
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                    controller: controllers[0],
                    decoration: InputDecoration(
                      labelText: t('Instance'),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        tooltip: t('Anonymous'),
                        icon: const Icon(Icons.navigate_next_rounded),
                        onPressed: () {
                          setPref('instance', trimUrl(controllers[0].text));
                          setPref('token', '');
                          setPref('authInstance', '');
                          runApp(MyApp(key: Key('${DateTime.now()}')));
                        },
                      ),
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.url],
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                    controller: controllers[1],
                    decoration: InputDecoration(
                      labelText: l['Auth instance']!,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.username],
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                    controller: controllers[2],
                    decoration: InputDecoration(
                      labelText: l['Username']!,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  TextFormField(
                    autofillHints: const [AutofillHints.password],
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
                    controller: controllers[3],
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: l['Password']!,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          child: Card(
                            elevation: 6,
                            shadowColor: Theme.of(context).primaryColor,
                            margin: const EdgeInsets.only(right: 16, top: 16),
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () async {
                                setPref(
                                  'instance',
                                  trimUrl(controllers[0].text),
                                );
                                setPref(
                                  'authInstance',
                                  trimUrl(controllers[1].text),
                                );
                                if (await login(
                                  controllers[2].text.trim(),
                                  controllers[3].text,
                                  false,
                                )) {
                                  runApp(MyApp(key: Key('${DateTime.now()}')));
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    l['Sign up']!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          elevation: 6,
                          shadowColor: Theme.of(context).primaryColor,
                          margin: const EdgeInsets.only(left: 16, top: 16),
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () async {
                              setPref('instance', trimUrl(controllers[0].text));
                              setPref('authInstance', trimUrl(controllers[1].text));
                              if (await login(controllers[2].text.trim(), controllers[3].text, true)) {
                                runApp(MyApp(key: Key('${DateTime.now()}')));
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  l['Log in']!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
*/
