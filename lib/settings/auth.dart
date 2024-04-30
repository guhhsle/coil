import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../functions/other.dart';
import '../pages/feed.dart';
import '../pages/subscriptions.dart';
import '../pages/user_playlists.dart';
import '../template/custom_card.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/prefs.dart';

Future<Layer> authSet(dynamic non) async => Layer(
      leading: (c) => [
        Expanded(
          child: CustomCard(
            Setting(
              'Sign up',
              Icons.person_add_rounded,
              ' ',
              (p0) => login(false),
            ),
          ),
        )
      ],
      action: Setting('', Icons.person_rounded, 'Login', (c) => login(true)),
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
  await setPref('token', '');
  if (pf['authInstance'] == '') return false;
  Response result = await post(
    Uri.https(pf['authInstance'], exists ? 'login' : 'register'),
    body: jsonEncode({'username': pf['username'], 'password': pf['password']}),
  );
  if (jsonDecode(result.body)['token'] != null) {
    await setPref('token', jsonDecode(result.body)['token']);
    unawaited(fetchUserPlaylists(true));
    unawaited(fetchSubscriptions(true));
    unawaited(fetchFeed());
    showSnack('Logged in', true);
    return true;
  } else {
    showSnack(jsonDecode(result.body)['error'], false);
  }
  return false;
}
