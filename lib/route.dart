import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sit/credentials/entity/login_status.dart';
import 'package:sit/credentials/widgets/oa_scope.dart';
import 'package:sit/game/2048/index.dart';
import 'package:sit/game/index.dart';
import 'package:sit/game/minesweeper/index.dart';
import 'package:sit/game/suika/index.dart';
import 'package:sit/index.dart';
import 'package:sit/me/edu_email/page/login.dart';
import 'package:sit/me/edu_email/page/outbox.dart';
import 'package:sit/school/class2nd/entity/attended.dart';
import 'package:sit/school/exam_result/page/gpa.dart';
import 'package:sit/school/exam_result/page/result.pg.dart';
import 'package:sit/school/library/page/history.dart';
import 'package:sit/school/library/page/login.dart';
import 'package:sit/school/library/page/borrowing.dart';
import 'package:sit/school/ywb/entity/service.dart';
import 'package:sit/school/ywb/page/details.dart';
import 'package:sit/school/ywb/page/service.dart';
import 'package:sit/school/ywb/page/application.dart';
import 'package:sit/settings/page/about.dart';
import 'package:sit/settings/page/language.dart';
import 'package:sit/settings/page/life.dart';
import 'package:sit/settings/page/proxy.dart';
import 'package:sit/settings/page/school.dart';
import 'package:sit/settings/page/storage.dart';
import 'package:sit/life/expense_records/page/records.dart';
import 'package:sit/life/expense_records/page/statistics.dart';
import 'package:sit/life/index.dart';
import 'package:sit/login/page/index.dart';
import 'package:sit/me/edu_email/page/inbox.dart';
import 'package:sit/network/page/index.dart';
import 'package:sit/settings/dev.dart';
import 'package:sit/settings/page/theme_color.dart';
import 'package:sit/timetable/init.dart';
import 'package:sit/timetable/page/p13n/background.dart';
import 'package:sit/timetable/page/p13n/cell_style.dart';
import 'package:sit/timetable/page/editor.dart';
import 'package:sit/timetable/page/p13n/palette_editor.dart';
import 'package:sit/widgets/not_found.dart';
import 'package:sit/school/oa_announce/entity/announce.dart';
import 'package:sit/school/oa_announce/page/details.dart';
import 'package:sit/school/exam_arrange/page/list.dart';
import 'package:sit/school/oa_announce/page/list.dart';
import 'package:sit/qrcode/page/scanner.dart';
import 'package:sit/school/class2nd/page/details.dart';
import 'package:sit/school/class2nd/page/activity.dart';
import 'package:sit/school/class2nd/page/attended.dart';
import 'package:sit/school/exam_result/page/evaluation.dart';
import 'package:sit/school/exam_result/page/result.ug.dart';
import 'package:sit/school/yellow_pages/page/index.dart';
import 'package:sit/settings/page/credentials.dart';
import 'package:sit/settings/page/developer.dart';
import 'package:sit/settings/page/index.dart';
import 'package:sit/me/index.dart';
import 'package:sit/school/index.dart';
import 'package:sit/settings/page/timetable.dart';
import 'package:sit/timetable/page/import.dart';
import 'package:sit/timetable/page/index.dart';
import 'package:sit/timetable/page/mine.dart';
import 'package:sit/timetable/page/p13n/palette.dart';
import 'package:sit/widgets/image.dart';
import 'package:sit/widgets/webview/page.dart';

final $Key = GlobalKey<NavigatorState>();
final $TimetableShellKey = GlobalKey<NavigatorState>();
final $SchoolShellKey = GlobalKey<NavigatorState>();
final $LifeShellKey = GlobalKey<NavigatorState>();
final $GameShellKey = GlobalKey<NavigatorState>();
final $MeShellKey = GlobalKey<NavigatorState>();

bool isLoginGuarded(BuildContext ctx) {
  if (Dev.demoMode) return false;
  final auth = ctx.auth;
  return auth.loginStatus != LoginStatus.validated && auth.credentials == null;
}

String? _loginRequired(BuildContext ctx, GoRouterState state) {
  if (isLoginGuarded(ctx)) return "/login?guard=true";
  return null;
}

FutureOr<String?> _redirectRoot(BuildContext ctx, GoRouterState state) {
  final auth = ctx.auth;
  if (auth.loginStatus == LoginStatus.never) {
// allow to access settings page.
    if (state.matchedLocation.startsWith("/tools")) return null;
    if (state.matchedLocation.startsWith("/settings")) return null;
// allow to access browser page.
    if (state.matchedLocation == "/browser") return null;
    return "/login";
  }
  return null;
}

Widget _onError(BuildContext context, GoRouterState state) {
  return NotFoundPage(state.uri.toString());
}

final _timetableShellRoute = GoRoute(
  path: "/timetable",
// Timetable is the home page.
  builder: (ctx, state) => const TimetablePage(),
);

final _timetableRoutes = [
  GoRoute(
    path: "/timetable/import",
    builder: (ctx, state) => const ImportTimetablePage(),
    redirect: _loginRequired,
  ),
  GoRoute(
    path: "/timetable/mine",
    builder: (ctx, state) => const MyTimetableListPage(),
  ),
  GoRoute(
    path: "/timetable/p13n",
    builder: (ctx, state) => const TimetableP13nPage(),
    routes: [
      GoRoute(
        path: "custom",
        builder: (ctx, state) => const TimetableP13nPage(tab: TimetableP13nTab.custom),
      ),
      GoRoute(
        path: "builtin",
        builder: (ctx, state) => const TimetableP13nPage(tab: TimetableP13nTab.builtin),
      ),
    ],
  ),
  GoRoute(
    path: "/timetable/palette/edit/:id",
    builder: (ctx, state) {
      final id = int.tryParse(state.pathParameters["id"] ?? "");
      if (id == null) throw 404;
      final palette = TimetableInit.storage.palette[id];
      if (palette == null) throw 404;
      return TimetablePaletteEditorPage(palette: palette);
    },
  ),
  GoRoute(
    path: "/timetable/edit/:id",
    builder: (ctx, state) {
      final id = int.tryParse(state.pathParameters["id"] ?? "");
      if (id == null) throw 404;
      final timetable = TimetableInit.storage.timetable[id];
      if (timetable == null) throw 404;
      return TimetableEditorPage(timetable: timetable);
    },
  ),
  GoRoute(
    path: "/timetable/cell-style",
    builder: (ctx, state) => const TimetableCellStyleEditor(),
  ),
  GoRoute(
    path: "/timetable/background",
    builder: (ctx, state) => const TimetableBackgroundEditor(),
  ),
];

final _schoolShellRoute = GoRoute(
  path: "/school",
  builder: (ctx, state) => const SchoolPage(),
);
final _lifeShellRoute = GoRoute(
  path: "/life",
  builder: (ctx, state) => const LifePage(),
);
final _gameShellRoute = GoRoute(
  path: "/game",
  builder: (ctx, state) => const GamePage(),
);
final _meShellRoute = GoRoute(
  path: "/me",
  builder: (ctx, state) => const MePage(),
);
final _toolsRoutes = [
  GoRoute(
    path: "/tools/network-tool",
    builder: (ctx, state) => const NetworkToolPage(),
  ),
  GoRoute(
    path: "/tools/scanner",
    parentNavigatorKey: $Key,
    builder: (ctx, state) => const ScannerPage(),
  ),
];
final _settingsRoute = GoRoute(
  path: "/settings",
  builder: (ctx, state) => const SettingsPage(),
  routes: [
    GoRoute(
      path: "language",
      builder: (ctx, state) => const LanguagePage(),
    ),
    GoRoute(
      path: "theme-color",
      builder: (ctx, state) => const ThemeColorPage(),
    ),
    GoRoute(
      path: "credentials",
      builder: (ctx, state) => const CredentialsPage(),
    ),
    GoRoute(
      path: "timetable",
      builder: (ctx, state) => const TimetableSettingsPage(),
    ),
    GoRoute(
      path: "school",
      builder: (ctx, state) => const SchoolSettingsPage(),
    ),
    GoRoute(
      path: "life",
      builder: (ctx, state) => const LifeSettingsPage(),
    ),
    GoRoute(
      path: "about",
      builder: (ctx, state) => const AboutSettingsPage(),
    ),
    GoRoute(
      path: "proxy",
      builder: (ctx, state) => const ProxySettingsPage(),
    ),
    GoRoute(
      path: "developer",
      builder: (ctx, state) => const DeveloperOptionsPage(),
      routes: [
        GoRoute(
          path: "local-storage",
          builder: (ctx, state) => const LocalStoragePage(),
        )
      ],
    ),
  ],
);
final _expenseRoute = GoRoute(
  path: "/expense-records",
  builder: (ctx, state) => const ExpenseRecordsPage(),
  redirect: _loginRequired,
  routes: [
    GoRoute(
      path: "statistics",
      builder: (ctx, state) => const ExpenseStatisticsPage(),
      redirect: _loginRequired,
    )
  ],
);

final _class2ndRoute = GoRoute(
  path: "/class2nd",
  builder: (ctx, state) => const ActivityListPage(),
  redirect: _loginRequired,
  routes: [
    GoRoute(
      path: "attended",
      builder: (ctx, state) => const AttendedActivityPage(),
      redirect: _loginRequired,
    ),
    GoRoute(
      path: "activity-details/:id",
      builder: (ctx, state) {
        final id = int.tryParse(state.pathParameters["id"] ?? "");
        if (id == null) throw 404;
        final enableApply = state.uri.queryParameters["enable-apply"] != null;
        final title = state.uri.queryParameters["title"];
        final time = DateTime.tryParse(state.uri.queryParameters["time"] ?? "");
        return Class2ndActivityDetailsPage(activityId: id, title: title, time: time, enableApply: enableApply);
      },
      redirect: _loginRequired,
    ),
    // TODO: using path para
    GoRoute(
      path: "attended-details",
      builder: (ctx, state) {
        final extra = state.extra;
        if (extra is Class2ndAttendedActivity) {
          return Class2ndAttendDetailsPage(extra);
        }
        throw 404;
      },
      redirect: _loginRequired,
    ),
  ],
);

final _oaAnnounceRoute = GoRoute(
  path: "/oa-announce",
  builder: (ctx, state) => const OaAnnounceListPage(),
  redirect: _loginRequired,
  routes: [
    // TODO: using path para
    GoRoute(
      path: "details",
      builder: (ctx, state) {
        final extra = state.extra;
        if (extra is OaAnnounceRecord) {
          return AnnounceDetailsPage(extra);
        }
        throw 404;
      },
    ),
  ],
);
final _eduEmailRoutes = [
  GoRoute(
    path: "/yellow-pages",
    builder: (ctx, state) => const YellowPagesListPage(),
  ),
  GoRoute(
    path: "/edu-email/login",
    builder: (ctx, state) => const EduEmailLoginPage(),
  ),
  GoRoute(
    path: "/edu-email/inbox",
    builder: (ctx, state) => const EduEmailInboxPage(),
  ),
  GoRoute(
    path: "/edu-email/outbox",
    builder: (ctx, state) => const EduEmailOutboxPage(),
  ),
];

final _ywbRoute = GoRoute(
  path: "/ywb",
  builder: (ctx, state) => const YwbServiceListPage(),
  redirect: _loginRequired,
  routes: [
    GoRoute(
      path: "mine",
      builder: (ctx, state) => const YwbMyApplicationListPage(),
    ),
    // TODO: using path para
    GoRoute(
      path: "details",
      builder: (ctx, state) {
        final extra = state.extra;
        if (extra is YwbService) {
          return YwbServiceDetailsPage(meta: extra);
        }
        throw 404;
      },
    ),
  ],
);

final _imageRoute = GoRoute(
  path: "/image",
  builder: (ctx, state) {
    final extra = state.extra;
    final data = state.uri.queryParameters["origin"] ?? extra as String?;
    if (data != null) {
      return ImageViewPage(
        data,
        title: state.uri.queryParameters["title"],
      );
    }
    throw 400;
  },
);

final _loginRoute = GoRoute(
  path: "/login",
  builder: (ctx, state) {
    final guarded = state.uri.queryParameters["guard"] == "true";
    return LoginPage(isGuarded: guarded);
  },
);

final _teacherEvalRoute = GoRoute(
  path: "/teacher-eval",
  builder: (ctx, state) => const TeacherEvaluationPage(),
  redirect: _loginRequired,
);

final _libraryRoutes = [
  GoRoute(
    path: "/library/login",
    builder: (ctx, state) => const LibraryLoginPage(),
  ),
  GoRoute(
    path: "/library/borrowing",
    builder: (ctx, state) => const LibraryBorrowingPage(),
  ),
  GoRoute(
    path: "/library/borrowing-history",
    builder: (ctx, state) => const LibraryMyBorrowingHistoryPage(),
  ),
];

final _examArrange = GoRoute(
  path: "/exam-arrange",
  builder: (ctx, state) => const ExamArrangementListPage(),
  redirect: _loginRequired,
);

final _examResultRoute = GoRoute(
  path: "/exam-result",
  routes: [
    GoRoute(path: "ug", builder: (ctx, state) => const ExamResultUgPage(), routes: [
      GoRoute(
        path: "gpa",
        builder: (ctx, state) => const GpaCalculatorPage(),
      ),
    ]),
    GoRoute(
      path: "pg",
      builder: (ctx, state) => const ExamResultPgPage(),
    ),
  ],
  redirect: _loginRequired,
);

final _browserRoute = GoRoute(
  path: "/browser",
  builder: (ctx, state) {
    var url = state.uri.queryParameters["url"] ?? state.extra;
    if (url is String) {
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "http://$url";
      }
      return WebViewPage(initialUrl: url);
    }
    throw 400;
  },
);
final _gameRoutes = [
  GoRoute(
    path: "/game/2048",
    builder: (ctx, state) {
      final continueGame = state.uri.queryParameters["continue"] != null;
      return Game2048Page(newGame: !continueGame);
    },
  ),
  GoRoute(
    path: "/game/minesweeper",
    builder: (ctx, state) {
      final continueGame = state.uri.queryParameters["continue"] != null;
      return GameMinesweeperPage(newGame: !continueGame);
    },
  ),
  GoRoute(
    path: "/game/suika",
    builder: (ctx, state) => const GameSuikaPage(),
  ),
];

GoRouter buildRouter(ValueNotifier<RoutingConfig> $routingConfig) {
  return GoRouter.routingConfig(
    routingConfig: $routingConfig,
    navigatorKey: $Key,
    initialLocation: "/",
    debugLogDiagnostics: kDebugMode,
    errorBuilder: _onError,
  );
}

RoutingConfig buildCommonRoutingConfig() {
  return RoutingConfig(
    redirect: _redirectRoot,
    routes: [
      GoRoute(
        path: "/",
        redirect: (ctx, state) => "/timetable",
      ),
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, navigationShell) {
          return MainStagePage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: $TimetableShellKey,
            routes: [
              _timetableShellRoute,
            ],
          ),
          if (!kIsWeb)
            StatefulShellBranch(
              navigatorKey: $SchoolShellKey,
              routes: [
                _schoolShellRoute,
              ],
            ),
          if (!kIsWeb)
            StatefulShellBranch(
              navigatorKey: $LifeShellKey,
              routes: [
                _lifeShellRoute,
              ],
            ),
          // StatefulShellBranch(
          //   navigatorKey: $GameShellKey,
          //   routes: [
          //     _gameShellRoute,
          //   ],
          // ),
          StatefulShellBranch(
            navigatorKey: $MeShellKey,
            routes: [
              _meShellRoute,
            ],
          ),
        ],
      ),
      ..._timetableRoutes,
      _browserRoute,
      _expenseRoute,
      _settingsRoute,
      ..._toolsRoutes,
      _class2ndRoute,
      _oaAnnounceRoute,
      ..._eduEmailRoutes,
      _ywbRoute,
      _examResultRoute,
      _examArrange,
      ..._libraryRoutes,
      _teacherEvalRoute,
      _loginRoute,
      _imageRoute,
      ..._gameRoutes,
    ],
  );
}

RoutingConfig buildTimetableFocusRouter() {
  return RoutingConfig(
    redirect: _redirectRoot,
    routes: [
      GoRoute(
        path: "/",
        redirect: (ctx, state) => "/timetable",
      ),
      _timetableShellRoute,
      ..._timetableRoutes,
      _schoolShellRoute,
      _gameShellRoute,
      _lifeShellRoute,
      _meShellRoute,
      _browserRoute,
      _expenseRoute,
      _settingsRoute,
      ..._toolsRoutes,
      _class2ndRoute,
      _oaAnnounceRoute,
      ..._eduEmailRoutes,
      _ywbRoute,
      _examResultRoute,
      _examArrange,
      ..._libraryRoutes,
      _teacherEvalRoute,
      _loginRoute,
      _imageRoute,
      ..._gameRoutes,
    ],
  );
}
