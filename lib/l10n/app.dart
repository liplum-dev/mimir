import 'package:sit/timetable/i18n.dart' as t;
import 'package:sit/school/i18n.dart' as s;
import 'package:sit/life/i18n.dart' as l;

class AppI18n {
  const AppI18n();
  final navigation = const _Navigation();
}

class _Navigation {
  const _Navigation();

  String get timetable => t.i18n.navigation;
  String get school => s.i18n.navigation;
  String get life => l.i18n.navigation;
  // String get game => t.i18n.navigation;
}
