import 'dart:async';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fit_system_screenshot/fit_system_screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:sit/credentials/widgets/oa_scope.dart';
import 'package:sit/files.dart';
import 'package:sit/qrcode/handle.dart';
import 'package:sit/r.dart';
import 'package:sit/route.dart';
import 'package:sit/session/widgets/scope.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/update/utils.dart';
import 'package:sit/utils/color.dart';
import 'package:system_theme/system_theme.dart';
import 'package:universal_platform/universal_platform.dart';

class MimirApp extends StatefulWidget {
  const MimirApp({super.key});

  @override
  State<MimirApp> createState() => _MimirAppState();
}

class _MimirAppState extends State<MimirApp> {
  final $theme = Settings.theme.listenThemeChange();
  final $routingConfig = ValueNotifier(
    Settings.focusTimetable ? buildTimetableFocusRouter() : buildCommonRoutingConfig(),
  );
  final $focusMode = Settings.listenFocusTimetable();
  late final router = buildRouter($routingConfig);

  @override
  void initState() {
    super.initState();
    $theme.addListener(refresh);
    $focusMode.addListener(refreshFocusMode);
    if (!kIsWeb) {
      fitSystemScreenshot.init();
    }
  }

  @override
  void dispose() {
    $theme.removeListener(refresh);
    $focusMode.removeListener(refreshFocusMode);
    fitSystemScreenshot.release();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (Settings.timetable.backgroundImage?.enabled == true) {
      precacheImage(FileImage(Files.timetable.backgroundFile), context);
    }
    super.didChangeDependencies();
  }

  void refresh() {
    setState(() {});
  }

  void refreshFocusMode() {
    $routingConfig.value = Settings.focusTimetable ? buildTimetableFocusRouter() : buildCommonRoutingConfig();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Settings.theme.themeColor ?? SystemTheme.accentColor.maybeAccent;

    ThemeData bakeTheme(ThemeData origin) {
      return origin.copyWith(
        platform: R.debugCupertino ? TargetPlatform.iOS : null,
        colorScheme: themeColor == null
            ? null
            : ColorScheme.fromSeed(
                seedColor: themeColor,
                brightness: origin.brightness,
              ),
        visualDensity: VisualDensity.comfortable,
        splashFactory: InkSparkle.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.vertical),
            TargetPlatform.windows: SharedAxisPageTransitionsBuilder(transitionType: SharedAxisTransitionType.vertical),
          },
        ),
      );
    }

    return Breakpoint(
      child: MaterialApp.router(
        title: R.appName,
        onGenerateTitle: (ctx) => "appName".tr(),
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        themeMode: Settings.theme.themeMode,
        theme: bakeTheme(ThemeData.light(
          useMaterial3: true,
        )),
        darkTheme: bakeTheme(ThemeData.dark(
          useMaterial3: true,
        )),
        builder: (ctx, child) => OaAuthManager(
          child: OaOnlineManager(
            child: _PostServiceRunner(
              child: child ?? const SizedBox(),
            ),
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
      ),
    );
  }
}

class _PostServiceRunner extends StatefulWidget {
  final Widget child;

  const _PostServiceRunner({
    required this.child,
  });

  @override
  State<_PostServiceRunner> createState() => _PostServiceRunnerState();
}

class _PostServiceRunnerState extends State<_PostServiceRunner> {
  StreamSubscription? $appLink;

  @override
  void initState() {
    super.initState();
    if (!(UniversalPlatform.isIOS || UniversalPlatform.isMacOS)) {
      Future.delayed(Duration.zero).then((value) async {
        await checkAppUpdate(
          context: $Key.currentContext!,
          delayAtLeast: const Duration(milliseconds: 3000),
          manually: false,
        );
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      $appLink = AppLinks().allUriLinkStream.listen((uri) async {
        final navigateCtx = $Key.currentContext;
        if (navigateCtx == null) return;
        await onHandleQrCodeUriData(context: navigateCtx, qrCodeData: uri);
      });
    });
  }

  @override
  void dispose() {
    $appLink?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
