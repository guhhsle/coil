import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../../pages/subscriptions.dart';
import '../../pages/user_playlists.dart';
import '../../template/functions.dart';
import '../../functions/other.dart';
import '../../template/layer.dart';
import '../../template/tile.dart';
import '../../pages/feed.dart';
import '../instances.dart';
import '../../data.dart';

class AuthLayer extends Layer {
  @override
  void construct() {
    action = Tile('Confirm', Icons.keyboard_return_rounded, '', () {
      login();
    });
    list = [
      Tile(
        Pref.authInstance.value == '' ? 'Authentication Instance' : '',
        Icons.lock_rounded,
        formatInstanceName(Pref.authInstance.value),
        () async {
          final instances = Instances()..show();
          final instance = await instances.completer.future;
          Pref.authInstance.set(instance);
        },
      ),
      Tile(
        Pref.username.value == '' ? 'Username' : '',
        Icons.person_rounded,
        Pref.username.value,
        () => getPrefInput(Pref.username).then((name) {
          Pref.username.set(name);
        }),
      ),
      Tile(
        Pref.password.value == '' ? 'Password' : '',
        Icons.password_rounded,
        Pref.password.value.replaceAll(RegExp(r'.'), '*'),
        () => getPrefInput(Pref.password).then((pass) {
          Pref.password.set(pass);
        }),
      ),
    ];
    trailing = [
      IconButton(
        icon: const Icon(Icons.logout_rounded),
        onPressed: () {
          Pref.token.set('');
          Pref.username.set('');
          Pref.password.set('');
          Pref.authInstance.set('');
        },
      ),
    ];
  }

  Future<bool> login() async {
    Pref.token.set('');
    if (Pref.authInstance.value == '') return false;
    late Response result;
    try {
      result = await post(
        Uri.https(Pref.authInstance.value, 'login'),
        body: jsonEncode({
          'username': Pref.username.value,
          'password': Pref.password.value,
        }),
      );
      String? error = jsonDecode(result.body)['error'];
      if (error != null) throw Exception(error);
    } catch (e) {
      debugPrint(e.toString());
      result = await post(
        Uri.https(Pref.authInstance.value, 'register'),
        body: jsonEncode({
          'username': Pref.username.value,
          'password': Pref.password.value,
        }),
      );
    }
    if (jsonDecode(result.body)['token'] != null) {
      Pref.token.set(jsonDecode(result.body)['token']);
      fetchUserPlaylists(true);
      fetchSubscriptions(true);
      fetchFeed();
      showSnack('Logged in', true);
      return true;
    } else {
      showSnack(jsonDecode(result.body)['error'], false);
    }
    return false;
  }
}
