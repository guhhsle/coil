import 'dart:async';
import 'dart:convert';

import '../data.dart';
import 'package:http/http.dart';

import '../functions/other.dart';
import '../functions/prefs.dart';
import 'playlist.dart';

Future<bool> login(
  String username,
  String password,
  bool exists,
) async {
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

Future<bool> subscribed(String channelId) async {
  Response result = await get(
    Uri.https(pf['authInstance'], 'subscribed', {
      'channelId': channelId,
    }),
    headers: {'Authorization': pf['token']},
  );
  return jsonDecode(result.body)['subscribed'];
}

Future<void> unSubscribe(String channelId, bool s) async {
  await post(
    Uri.https(pf['authInstance'], s ? 'unsubscribe' : 'subscribe'),
    headers: {
      'Authorization': pf['token'],
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'channelId': channelId}),
  );
}

Future<void> feed() async {
  if (pf['token'] == '') return;
  Response response = await get(
    Uri.https(pf['authInstance'], 'feed', {'authToken': pf['token']}),
  );
  userSubscriptions.value = jsonDecode(utf8.decode(response.bodyBytes));
}
