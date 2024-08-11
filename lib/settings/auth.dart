import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../data.dart';
import '../functions/other.dart';
import '../pages/feed.dart';
import '../pages/subscriptions.dart';
import '../pages/user_playlists.dart';
import '../template/functions.dart';
import '../template/layer.dart';
import '../template/prefs.dart';

Future<Layer> authSet(dynamic non) async => Layer(
      action: Setting(
        'Confirm',
        Icons.keyboard_return_rounded,
        '',
        (c) => login(),
      ),
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
              'Username',
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
              'Password',
            );
            setPref('password', newPassword);
          },
        ),
      ],
    );

Future<bool> login() async {
  await setPref('token', '');
  if (pf['authInstance'] == '') return false;
  late Response result;
  try {
    result = await post(
      Uri.https(pf['authInstance'], 'login'),
      body: jsonEncode(
        {'username': pf['username'], 'password': pf['password']},
      ),
    );
    String? error = jsonDecode(result.body)['error'];
    if (error != null) throw Exception(error);
  } catch (e) {
    debugPrint(e.toString());
    result = await post(
      Uri.https(pf['authInstance'], 'register'),
      body: jsonEncode(
        {'username': pf['username'], 'password': pf['password']},
      ),
    );
  }
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
