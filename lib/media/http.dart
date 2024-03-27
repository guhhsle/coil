// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

import '../audio/handler.dart';
import '../data.dart';
import '../layer.dart';
import 'media.dart';

extension MediaHTTP on Media {
  Future<void> lyrics() async {
    currentLyrics.value = '...';
    if (extras['lyrics'] == null) {
      Response response = await get(
        Uri.https(pf['lyricsApi'], 'next/$id'),
      );
      String lyricsId = jsonDecode(response.body)['lyricsId'];
      response = await get(
        Uri.https(pf['lyricsApi'], 'lyrics/$lyricsId'),
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
        extras['lyrics'] = null;
        currentLyrics.value = '404: Error Not Found';
        return;
      }
      extras['lyrics'] = '$text\n\n\n\n$source';
    }
    currentLyrics.value = extras['lyrics'];
  }

  Future<void> forceLoad() async {
    if (extras['url'] == '' && extras['offline'] == null) {
      try {
        if (Handler().tryLoadFromCache(this)) return;

        Response result = await get(Uri.https(pf['instance'], 'streams/$id'));
        Map raw = jsonDecode(result.body);
        List audios = raw['audioStreams'];

        Map<String, int> bitrates = {};
        for (int i = 0; i < audios.length; i++) {
          bitrates.addAll({audios[i]['url']: audios[i]['bitrate']});
        }
        Map<String, int> sorted = extras['audioUrls'] = Map.fromEntries(
          bitrates.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)),
        );
        String url = sorted.keys.first;
        int diff = ((pf['bitrate'] as int) - sorted.values.first).abs();
        if (pf['bitrate'] == 180000) {
          url = sorted.keys.last;
        } else if (pf['bitrate'] != 30000) {
          for (int i = 1; i < sorted.length; i++) {
            if (((pf['bitrate'] as int) - sorted.values.elementAt(i)).abs() < diff) {
              url = sorted.keys.elementAt(i);
              diff = ((pf['bitrate'] as int) - sorted.values.elementAt(i)).abs();
            }
          }
        }
        extras['url'] = url;
        (extras['video'] as List<Map>).clear();
        for (int i = raw['videoStreams'].length - 1; i >= 0; i--) {
          if (!raw['videoStreams'][i]['videoOnly']) {
            Map video = raw['videoStreams'][i];
            (extras['video'] as List<Map>).add(
              {
                'url': video['url'],
                'format': video['format'],
                'quality': video['quality'],
              },
            );
          }
        }
      } catch (e) {
        //FORMAT ERROR
      }
    }
  }

  void showLinks(BuildContext context) {
    Layer layer = Layer(
      action: Setting('Links', Icons.link_rounded, '', (c) {}),
      list: [
        Setting(
          '',
          Icons.file_download_outlined,
          'Audio',
          (c) async {
            if (await canLaunchUrl(Uri.parse(extras['url']))) {
              Map<String, int> map = extras['audioUrls'];
              showSheet(
                scroll: true,
                hidePrev: c,
                func: (non) async => Layer(
                  action: Setting(
                    'Bitrate',
                    Icons.graphic_eq_rounded,
                    '',
                    (c) {},
                  ),
                  list: [
                    for (int i = map.length - 1; i >= 0; i--)
                      Setting(
                        '${map.keys.elementAt(i) == extras['url'] ? '>   ' : ''}${map.values.elementAt(i)}',
                        Icons.graphic_eq_rounded,
                        '',
                        (c) async => await launchUrl(
                          Uri.parse(map.keys.elementAt(i)),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                  ],
                ),
              );
            }
          },
        ),
        Setting(
          '',
          Icons.video_label_rounded,
          'Piped',
          (c) async {
            if (await canLaunchUrl(Uri.parse('${pf['watchOnPiped']}$id'))) {
              await launchUrl(
                Uri.parse('https://piped.video/watch?v=$id'),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ),
        for (int i = 0; i < (extras['video'] as List<Map>).length; i++)
          Setting(
            extras['video'][i]['quality'],
            Icons.theaters_rounded,
            extras['video'][i]['format'],
            (c) async {
              if (await canLaunchUrl(Uri.parse(extras['video'][i]['url']))) {
                await launchUrl(
                  Uri.parse(extras['video'][i]['url']),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          ),
      ],
    );
    showSheet(
      func: (non) async => layer,
      scroll: true,
      hidePrev: context,
    );
  }
}
