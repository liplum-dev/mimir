import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/timetable/i18n.dart' as $timetable;
import 'package:mimir/school/i18n.dart' as $school;
import 'package:mimir/life/i18n.dart' as $life;
import 'package:mimir/me/i18n.dart' as $me;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rettulf/rettulf.dart';

class MainStagePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainStagePage({super.key, required this.navigationShell});

  @override
  State<MainStagePage> createState() => _MainStagePageState();
}

typedef _NavigationDest = ({Widget icon, Widget activeIcon, String label});

extension _NavigationDestX on _NavigationDest {
  BottomNavigationBarItem toBarItem() {
    return BottomNavigationBarItem(icon: icon, activeIcon: activeIcon, label: label);
  }

  NavigationRailDestination toRailDest() {
    return NavigationRailDestination(icon: icon, selectedIcon: activeIcon, label: label.text());
  }

  BottomNavigationBarItem toCupertinoBarItem() {
    return BottomNavigationBarItem(icon: icon, activeIcon: activeIcon, label: label);
  }
}

class _MainStagePageState extends State<MainStagePage> {
  var currentStage = 0;
  late var items = buildItems();

  List<({String route, ({Widget icon, Widget activeIcon, String label}) item})> buildItems() {
    return [
      (
        route: "/timetable",
        item: (
          icon: const Icon(Icons.calendar_month_outlined),
          activeIcon: const Icon(Icons.calendar_month),
          label: $timetable.i18n.navigation,
        )
      ),
      (
        route: "/school",
        item: (
          icon: const Icon(Icons.school_outlined),
          activeIcon: const Icon(Icons.school),
          label: $school.i18n.navigation,
        )
      ),
      (
        route: "/life",
        item: (
          icon: const Icon(Icons.spa_outlined),
          activeIcon: const Icon(Icons.spa),
          label: $life.i18n.navigation,
        )
      ),
      (
        route: "/me",
        item: (
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: $me.i18n.navigation,
        )
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    items = buildItems();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return isCupertino ? buildCupertino() : buildMaterial();
  }

  Widget buildMaterial() {
    if (context.isPortrait) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          useLegacyColorScheme: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          currentIndex: getSelectedIndex(),
          onTap: onItemTapped,
          items: items.map((e) => e.item.toBarItem()).toList(),
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            selectedIndex: getSelectedIndex(),
            onDestinationSelected: onItemTapped,
            destinations: items.map((e) => e.item.toRailDest()).toList(),
          ),
          const VerticalDivider(),
          widget.navigationShell.expanded(),
        ].row(),
      );
    }
  }

  Widget buildCupertino() {
    return CupertinoTabScaffold(
      resizeToAvoidBottomInset: false,
      tabBar: CupertinoTabBar(
        items: items.map((e) => e.item.toCupertinoBarItem()).toList(),
        currentIndex: getSelectedIndex(),
        onTap: onItemTapped,
      ),
      tabBuilder: (_, i) => widget.navigationShell,
    );
  }

  int getSelectedIndex() {
    final location = GoRouterState.of(context).uri.toString();
    return items.indexWhere((e) => location.startsWith(e.route));
  }

  void onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

abstract class DrawerDelegateProtocol {
  const DrawerDelegateProtocol();

  void openDrawer();

  void closeDrawer();

  void openEndDrawer();

  void closeEndDrawer();
}

class DrawerDelegate extends DrawerDelegateProtocol {
  final GlobalKey<ScaffoldState> key;

  const DrawerDelegate(this.key);

  @override
  void openDrawer() {
    key.currentState?.openDrawer();
  }

  @override
  void closeDrawer() {
    key.currentState?.closeDrawer();
  }

  @override
  void openEndDrawer() {
    key.currentState?.openEndDrawer();
  }

  @override
  void closeEndDrawer() {
    key.currentState?.closeEndDrawer();
  }
}
