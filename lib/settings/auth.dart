import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../functions/other.dart';
import '../functions/prefs.dart';
import '../data.dart';
import '../layer.dart';
import '../widgets/user_playlists.dart';

Future<Layer> authSet(dynamic non) async => Layer(
      leading: (c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: IconButton(
          icon: const Icon(Icons.person_add_rounded),
          onPressed: () => login(false),
        ),
      ),
      action: Setting('Login', Icons.person_rounded, '', (c) => login(true)),
      list: [
        Setting(
          pf['authInstance'] == '' ? 'Authentication Instance' : '',
          Icons.lock_rounded,
          formatInstanceName(pf['authInstance']),
          (c) async {
            String newAuth = await instanceHistory();
            setPref('authInstance', newAuth);
          },
        ),
        Setting(
          pf['username'] == '' ? 'Username' : '',
          Icons.person_rounded,
          pf['username'],
          (c) async {
            String newUsername = await getInput(
              pf['username'],
              hintText: 'Username',
            );
            setPref('username', newUsername);
          },
        ),
        Setting(
          pf['password'] == '' ? 'Password' : '',
          Icons.password_rounded,
          pf['password'].replaceAll(RegExp(r'.'), '*'),
          (c) async {
            String newPassword = await getInput(
              pf['password'],
              hintText: 'Password',
            );
            setPref('password', newPassword);
          },
        ),
      ],
    );

Future<bool> login(bool exists) async {
  setPref('token', '');
  if (pf['authInstance'] == '') return false;
  Response result = await post(
    Uri.https(pf['authInstance'], exists ? 'login' : 'register'),
    body: jsonEncode({'username': pf['username'], 'password': pf['password']}),
  );
  if (jsonDecode(result.body)['token'] != null) {
    setPref('token', jsonDecode(result.body)['token']);
    unawaited(fetchUserPlaylists(true));
    showSnack('Logged in', true);
    return true;
  } else {
    showSnack(jsonDecode(result.body)['error'], false);
  }
  return false;
}
