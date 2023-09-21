import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mimir/credential/widgets/oa_scope.dart';
import 'package:mimir/r.dart';
import 'package:mimir/route.dart';
import 'package:mimir/session/widgets/scope.dart';
import 'package:mimir/settings/settings.dart';

class MimirApp extends StatefulWidget {
  const MimirApp({super.key});

  @override
  State<MimirApp> createState() => _MimirAppState();
}

class _MimirAppState extends State<MimirApp> {
  final onThemeChanged = Settings.listenThemeChange();

  @override
  void initState() {
    super.initState();
    onThemeChanged.addListener(refresh);
  }

  @override
  void dispose() {
    onThemeChanged.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Settings.themeColor ?? Colors.red;

    ThemeData bakeTheme(ThemeData origin) {
      return origin.copyWith(
        platform: R.debugCupertino ? TargetPlatform.iOS : null,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: origin.brightness,
        ),
        visualDensity: VisualDensity.comfortable,
        appBarTheme: origin.appBarTheme.copyWith(
          backgroundColor: Colors.transparent,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.horizontal),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.vertical),
            TargetPlatform.windows: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.vertical),
          },
        ),
      );
    }

    return MaterialApp.router(
      title: R.appName,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: Settings.themeMode,
      theme: bakeTheme(ThemeData.light(
        useMaterial3: true,
      )),
      darkTheme: bakeTheme(ThemeData.dark(
        useMaterial3: true,
      )),
      builder: (ctx, child) => OaAuthManager(
        child: OaOnlineManager(
          child: child ?? const SizedBox(),
        ),
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.unknown
        },
      ),
    );
  }
}
