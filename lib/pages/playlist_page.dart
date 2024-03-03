// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:coil/layer.dart';
import 'package:coil/playlist.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../functions.dart';
import '../services/audio.dart';
import '../services/export.dart';
import '../services/generate.dart';
import '../services/playlist.dart';
import '../widgets/body.dart';
import '../widgets/song_tile.dart';

class PlaylistPage extends StatefulWidget {
  final String url;
  final bool user;
  final List<int> path;

  const PlaylistPage({
    Key? key,
    required this.url,
    required this.path,
    this.user = false,
  }) : super(key: key);

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  bool generating = false;
  late Playlist list;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: refreshPlaylist,
      builder: (context, snapshot, child) {
        return FutureBuilder<Playlist>(
          future: loadPlaylist(widget.url, widget.path),
          builder: (context, snap) {
            if (!snap.hasData) {
              return Scaffold(
                appBar: AppBar(),
                body: Body(child: Container()),
              );
            }
            list = snap.data!;
            queueLoading = list.list.toList();
            unawaited(preload(range: 10));
            return Scaffold(
              floatingActionButton: const Float(),
              appBar: AppBar(
                title: TextFormField(
                  maxLines: 1,
                  maxLength: 24,
                  initialValue: widget.user
                      ? list.name
                      : formatList(
                          list.name,
                        ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onFieldSubmitted: (title) async => await renamePlaylist(
                    playlistId: widget.url,
                    newName: title,
                  ),
                ),
                actions: [
                  const TopIcon(),
                  IconButton(
                    tooltip: l['Generate similar'],
                    onPressed: () async {
                      setState(() => generating = true);
                      await generate(list.list).then(
                        (v) => setState(() => generating = v),
                      );
                      skipTo(0);
                    },
                    icon: generating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Theme.of(context).appBarTheme.foregroundColor,
                            ),
                          )
                        : const Icon(
                            Icons.track_changes_rounded,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      tooltip: l['Menu'],
                      onPressed: () {
                        showSheet(
                          func: (non) {
                            bool b = pf['bookmarks'].contains(widget.url);
                            return Layer(
                              action: Setting(
                                'Refresh',
                                Icons.refresh_rounded,
                                '',
                                (c) async {
                                  List<int> path = widget.path.toList();
                                  list = await loadPlaylist(
                                      widget.url,
                                      !path.remove(2) ? path : path
                                        ..add(2));
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                              ),
                              list: [
                                Setting(
                                  'Shuffle',
                                  Icons.low_priority_rounded,
                                  '',
                                  (c) {
                                    load(list.list);
                                    shuffle();
                                    skipTo(0);
                                    Navigator.of(c).pop();
                                  },
                                ),
                                Setting(
                                  b ? 'Remove from bookmarks' : 'Bookmark',
                                  b ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  '',
                                  (c) {
                                    if (b) {
                                      (pf['bookmarks'] as List<String>).remove(widget.url);
                                    } else {
                                      (pf['bookmarks'] as List<String>).add(widget.url);
                                    }
                                    setPref('bookmarks', pf['bookmarks']);
                                    unawaited(fetchBookmarks());
                                  },
                                ),
                                Setting(
                                  'Export',
                                  Icons.settings_backup_restore_rounded,
                                  '',
                                  (c) async {
                                    await exportOther(snap.data!);
                                    Navigator.of(c).pop();
                                  },
                                ),
                                Setting(
                                  'Creator',
                                  Icons.person_rounded,
                                  list.uploader,
                                  (c) {},
                                ),
                                Setting(
                                  'Items',
                                  Icons.numbers_rounded,
                                  '${list.items}',
                                  (c) {},
                                ),
                                Setting(
                                  'Delete',
                                  Icons.delete_forever_rounded,
                                  'Forever',
                                  (c) => showSheet(
                                    func: (non) => Layer(
                                      action: Setting(
                                        'Delete',
                                        Icons.delete_forever_rounded,
                                        '',
                                        (c) async {
                                          await deletePlaylist(widget.url);
                                          Navigator.of(c).pop();
                                        },
                                      ),
                                      list: [],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  )
                ],
              ),
              body: Body(
                child: RefreshIndicator(
                  onRefresh: () async {
                    List<int> path = widget.path.toList();
                    list = await loadPlaylist(
                        widget.url,
                        !path.remove(2) ? path : path
                          ..add(2));
                    setState(() {});
                  },
                  child: ListView.builder(
                    physics: scrollPhysics,
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: list.list.length,
                    itemBuilder: (context, i) => SongTile(list: list.list, i: i),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
