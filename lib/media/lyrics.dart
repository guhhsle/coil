import 'package:http/http.dart';
import 'dart:convert';
import 'media.dart';
import '../data.dart';

extension MediaLyrics on Media {
  Future<void> getLyrics() async {
    currentLyrics.value = '...';
    if (lyrics == null) {
      Response response = await get(
        Uri.https(Pref.lyricsAPI.value, 'next/$id'),
      );
      String lyricsId = jsonDecode(response.body)['lyricsId'];
      response = await get(
        Uri.https(Pref.lyricsAPI.value, 'lyrics/$lyricsId'),
      );
      String text = jsonDecode(utf8.decode(response.bodyBytes))['text'] ?? '';
      for (int i = 0; i < text.length; i++) {
        if (text[i] == '\n') {
          String help = text;
          text = '${help.substring(0, i)}\n\n${help.substring(i + 1)}';
          i++;
        }
      }
      String source = jsonDecode(response.body)['source'] ?? '';
      if (text == '') {
        lyrics = null;
        currentLyrics.value = '404: Error Not Found';
        return;
      }
      lyrics = '$text\n\n\n\n$source';
    }
    currentLyrics.value = lyrics ?? '';
  }
}
