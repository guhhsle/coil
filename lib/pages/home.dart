import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data.dart';
import '../functions/other.dart';
import '../template/animated_text.dart';
import '../template/custom_chip.dart';
import '../template/data.dart';
import '../template/functions.dart';
import '../template/prefs.dart';
import '../template/settings.dart';
import '../widgets/frame.dart';
import 'bookmarks.dart';
import 'feed.dart';
import 'local.dart';
import 'search.dart';
import 'user_playlists.dart';
import 'subscriptions.dart';
import 'trending.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  @override
  initState() {
    selectedHome = pf['homeOrder'][0];
    homeMap.clear();
    for (int i = 0; i < 6; i++) {
      homeMap.addAll({
        pf['homeOrder'][i]: {
          'Playlists': const UserPlaylists(),
          'Offline': const LocalSongs(),
          'Bookmarks': const Bookmarks(),
          'Feed': const Feed(),
          'Trending': const Trending(),
          'Subscriptions': const Subscriptions(),
        }[pf['homeOrder'][i]]!
      });
    }
    animationController = AnimationController(vsync: this);
    unawaited(fetchUserPlaylists(false));
    unawaited(getLocal());
    unawaited(fetchBookmarks());
    unawaited(fetchFeed());
    unawaited(trending());
    unawaited(fetchSubscriptions(false));
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
    return Frame(
      automaticallyImplyLeading: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: InkWell(
          onTap: () async {
            String instance = await instanceHistory();
            setPref('instance', instance);
            barText.value = formatInstanceName(instance);
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
        IconButton(
          tooltip: t('Search'),
          icon: const Icon(Icons.fiber_manual_record_outlined),
          onPressed: () => goToPage(const Search()),
        ),
        IconButton(
          tooltip: t('Menu'),
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => goToPage(const PageSettings()),
        ),
      ],
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
                  barText.value = t(selectedHome);
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
    );
  }
}

class HomeTags extends StatelessWidget {
  const HomeTags({super.key});

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
