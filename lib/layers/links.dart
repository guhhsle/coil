import 'package:coil/media/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import '../data.dart';
import '../template/layer.dart';
import '../template/tile.dart';
import '../media/media.dart';

class MediaLinks extends Layer {
  Media media;
  MediaLinks(this.media);
  @override
  void construct() async {
    await media.forceLoad();
    action = Tile('Links', Icons.link_rounded);
    list = [
      Tile('', Icons.file_download_outlined, 'Audio', () {
        Navigator.of(context).pop();
        AudioLinks(media).show();
      }),
      Tile('', Icons.tv_rounded, 'Alternative', () {
        launchUrl(
          Uri.parse('https://${Pref.alternative.value}/watch?v=${media.id}'),
          mode: LaunchMode.externalApplication,
        );
      }),
      for (MediaLink link in media.videoUrls)
        Tile(link.quality!, Icons.theaters_rounded, link.format!, () {
          launchUrl(
            Uri.parse(link.url),
            mode: LaunchMode.externalApplication,
          );
        }),
    ];
    notifyListeners();
  }
}

class AudioLinks extends MediaLinks {
  AudioLinks(super.media);
  @override
  void construct() {
    scroll = true;
    action = Tile('Bitrate', Icons.graphic_eq_rounded);
    list = [
      for (MediaLink link in media.audioUrls)
        Tile(
          '${link.url == media.audioUrl ? '>   ' : ''}${link.bitrate}',
          Icons.graphic_eq_rounded,
          link.format ?? '',
          () => launchUrl(
            Uri.parse(link.url),
            mode: LaunchMode.externalApplication,
          ),
        ),
    ].reversed;
  }
}
