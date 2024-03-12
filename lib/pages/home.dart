import 'dart:async';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../functions/audio.dart';
import '../functions/cache.dart';
import '../functions/other.dart';
import '../functions/prefs.dart';
import '../http/account.dart';
import '../http/playlist.dart';
import '../layer.dart';
import '../widgets/animated_text.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets/body.dart';
import '../widgets/bookmarks.dart';
import '../widgets/custom_chip.dart';
import '../widgets/local.dart';
import '../widgets/subscriptions.dart';
import '../widgets/trending.dart';
import '../widgets/user_playlists.dart';
import 'search.dart';
import 'settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

Map<String, Widget> homeMap = {};

String getInstanceName(String str) {
  int i = 0;
  while (str[i] != '.') {
    i++;
  }
  return str.substring(i + 1);
}

String selectedHome = 'Playlists';
ValueNotifier<String> barText = ValueNotifier(getInstanceName(pf['instance']));
PageController pageController = PageController();
ScrollController scrollController = ScrollController();
GlobalKey key = GlobalKey(debugLabel: 'Tags');

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  @override
  initState() {
    selectedHome = pf['homeOrder'][0];
    homeMap.clear();
    for (int i = 0; i < 5; i++) {
      homeMap.addAll({
        pf['homeOrder'][i]: {
          'Playlists': const UserPlaylists(),
          'Offline': const LocalSongs(),
          'Bookmarks': const Bookmarks(),
          'Subscriptions': const Subscriptions(),
          'Trending': const Trending()
        }[pf['homeOrder'][i]]!
      });
    }
    animationController = AnimationController(vsync: this);
    unawaited(fetchUserPlaylists(false));
    unawaited(getLocal());
    unawaited(fetchBookmarks());
    unawaited(feed());
    unawaited(trending());
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 32),
      () => SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //bottomSheet: const ScrollableBottomPlayer(),
      floatingActionButton: const Float(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: InkWell(
            onTap: () {
              List<String> history = pf['instanceHistory'];
              showSheet(
                scroll: true,
                func: (non) => Layer(
                  action: Setting(
                    pf['instance'],
                    Icons.domain_rounded,
                    '',
                    (c) async => await launchUrl(
                      Uri.parse('https://github.com/TeamPiped/Piped/wiki/Instances'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  list: [
                    for (int i = 0; i < history.length; i++)
                      Setting(
                        history[i],
                        Icons.remove_rounded,
                        '',
                        (c) async {
                          setPref('instance', history[i]);
                          barText.value = getInstanceName(history[i]);
                          Navigator.of(context).pop();
                        },
                        secondary: (c) {
                          pf['instanceHistory'].removeAt(i);
                          setPref('instanceHistory', pf['instanceHistory']);
                        },
                      ),
                    Setting(
                      'New',
                      Icons.add_rounded,
                      '',
                      (c) async {
                        String newInstance = await getInput('');
                        pf['instanceHistory'].add(newInstance);
                        setPref('instanceHistory', pf['instanceHistory']);
                        setPref('instance', newInstance, refresh: true);
                        barText.value = getInstanceName(newInstance);
                      },
                    ),
                  ],
                ),
              );
            },
            child: ValueListenableBuilder(
              valueListenable: barText,
              builder: (context, value, child) => AnimatedText(
                text: value,
                speed: const Duration(milliseconds: 48),
                style: Theme.of(context).appBarTheme.titleTextStyle!,
                key: ValueKey(value),
              ),
            ),
          ),
        ),
        actions: [
          const TopIcon(),
          IconButton(
            tooltip: l['Search'],
            icon: const Icon(Icons.fiber_manual_record_outlined),
            onPressed: () => showSearch(context: context, delegate: Delegate()),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: l['Menu'],
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => goToPage(const PageSettings()),
            ),
          ),
        ],
      ),
      body: Body(
        child: Column(
          children: [
            pf['tags'] == 'Top'
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: HomeTags(key: key),
                  )
                : Container(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: pf['tags'] != 'Top' ? 16 : 0,
                ),
                child: PageView(
                  physics: scrollPhysics,
                  controller: pageController,
                  onPageChanged: (index) {
                    selectedHome = homeMap.keys.elementAt(index);
                    barText.value = l[selectedHome];
                    if (calculateShift(context, index, homeMap) != null) {
                      scrollController.animateTo(
                        calculateShift(context, index, homeMap)!,
                        duration: const Duration(milliseconds: 256),
                        curve: Curves.easeOutQuad,
                      );
                    }
                    setState(() {});
                  },
                  children: homeMap.values.toList(),
                ),
              ),
            ),
            pf['tags'] == 'Bottom' ? HomeTags(key: key) : Container(),
          ],
        ),
      ),
    );
  }
}

class HomeTags extends StatefulWidget {
  const HomeTags({super.key});

  @override
  State<HomeTags> createState() => _HomeTagsState();
}

class _HomeTagsState extends State<HomeTags> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 64,
      child: ListView.builder(
        controller: scrollController,
        physics: scrollPhysics,
        scrollDirection: Axis.horizontal,
        itemCount: homeMap.length,
        itemBuilder: (context, i) => CustomChip(
          selected: selectedHome == homeMap.keys.elementAt(i),
          onSelected: (val) => pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 256),
            curve: Curves.easeOutQuad,
          ),
          label: homeMap.keys.elementAt(i),
        ),
      ),
    );
  }
}

double? calculateShift(BuildContext context, int index, Map map) {
  double tagsLength = pf['locale'] == 'ja' ? 28 : 22;
  double wantedShift = index == 0 ? 0 : 28;
  double word = pf['locale'] == 'ja' ? 14 : 8.45;
  double width = MediaQuery.of(context).size.width;
  for (int i = 0; i < homeMap.length; i++) {
    tagsLength += 24 + (l[map.keys.elementAt(i)] as String).length * word;
  }
  for (int i = 0; i < index - 1; i++) {
    wantedShift += 24 + (l[map.keys.elementAt(i)] as String).length * word;
  }
  double maxShift = 72 + tagsLength - width;

  if (wantedShift < maxShift) {
    return wantedShift;
  } else if (tagsLength > width) {
    return maxShift;
  } else {
    return null;
  }
}
