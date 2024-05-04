import 'package:easy_localization/easy_localization.dart';
import 'package:sit/l10n/common.dart';
import 'package:sit/school/i18n.dart';

const i18n = _I18n();

class _I18n with CommonI18nMixin {
  const _I18n();

  static const ns = "timetable";
  final time = const TimeI18n();
  final mine = const _Mine();
  final p13n = const _P13n();
  final import = const _Import();
  final export = const _Export();
  final course = const CourseI18n();
  final screenshot = const _Screenshot();
  final editor = const _Editor();
  final issue = const _Issue();
  final patch = const _Patch();
  final freeTip = const _FreeTip();
  final campus = const CampusI10n();
  final settings = const _Settings();

  String get navigation => "$ns.navigation".tr();

  String weekOrderedName({required int number}) => "$ns.weekOrderedName".tr(args: [number.toString()]);

  String get startWith => "$ns.startWith".tr();

  String get jump => "$ns.jump".tr();

  String get findToday => "$ns.findToday".tr();

  String get focusTimetable => "$ns.focusTimetable".tr();

  String get signature => "$ns.signature".tr();

  String get signaturePlaceholder => "$ns.signaturePlaceholder".tr();

  String get lunchtime => "$ns.lunchtime".tr();

  String get dinnertime => "$ns.dinnertime".tr();
}

class _Mine {
  const _Mine();

  static const ns = "${_I18n.ns}.mine";

  String get title => "$ns.title".tr();

  String get exportFile => "$ns.exportFile".tr();

  String get exportCalendar => "$ns.exportCalendar".tr();

  String get patch => "$ns.patch".tr();

  String get deleteRequest => "$ns.deleteRequest".tr();

  String get deleteRequestDesc => "$ns.deleteRequestDesc".tr();

  String get emptyTip => "$ns.emptyTip".tr();

  String get details => "$ns.details".tr();
}

class _P13n {
  const _P13n();

  static const ns = "${_I18n.ns}.p13n";
  final cell = const _CellStyle();
  final palette = const _Palette();
  final background = const _Background();

  String get title => "$ns.title".tr();

  ({String name, String place, List<String> teachers}) livePreview(int index) {
    return (
      name: "$ns.livePreview.$index.name".tr(),
      place: "$ns.livePreview.$index.place".tr(),
      teachers: "$ns.livePreview.$index.teachers".tr().split(","),
    );
  }
}

class _CellStyle {
  const _CellStyle();

  static const ns = "${_P13n.ns}.cellStyle";

  String get title => "$ns.title".tr();

  String get showTeachers => "$ns.showTeachers.title".tr();

  String get showTeachersDesc => "$ns.showTeachers.desc".tr();

  String get grayOut => "$ns.grayOut.title".tr();

  String get grayOutDesc => "$ns.grayOut.desc".tr();

  String get harmonize => "$ns.harmonize.title".tr();

  String get harmonizeDesc => "$ns.harmonize.desc".tr();

  String get alpha => "$ns.alpha".tr();
}

class _Palette {
  const _Palette();

  static const ns = "${_P13n.ns}.palette";

  String get title => "$ns.title".tr();

  String get fab => "$ns.fab".tr();

  String get customTab => "$ns.tab.custom".tr();

  String get builtinTab => "$ns.tab.builtin".tr();

  String get infoTab => "$ns.tab.info".tr();

  String get colorsTab => "$ns.tab.colors".tr();

  String get newPaletteName => "$ns.newPaletteName".tr();

  String get deleteRequest => "$ns.deleteRequest".tr();

  String get deleteRequestDesc => "$ns.deleteRequestDesc".tr();

  String get addColor => "$ns.addColor".tr();

  String get name => "$ns.name".tr();

  String get namePlaceholder => "$ns.namePlaceholder".tr();

  String get author => "$ns.author".tr();

  String get authorPlaceholder => "$ns.authorPlaceholder".tr();

  String get color => "$ns.color".tr();

  String get details => "$ns.details".tr();
}

class _Background {
  const _Background();

  static const ns = "${_P13n.ns}.background";

  String get title => "$ns.title".tr();

  String get pickTip => "$ns.pickTip".tr();

  String get selectedImage => "$ns.selectedImage".tr();

  String get imageURL => "$ns.imageURL".tr();

  String get invalidURL => "$ns.invalidURL".tr();

  String get invalidURLDesc => "$ns.invalidURLDesc".tr();

  String get opacity => "$ns.opacity".tr();

  String get repeat => "$ns.repeat.title".tr();

  String get repeatDesc => "$ns.repeat.desc".tr();

  String get antialias => "$ns.antialias.title".tr();

  String get antialiasDesc => "$ns.antialias.desc".tr();
}

class _Screenshot {
  const _Screenshot();

  static const ns = "${_I18n.ns}.screenshot";

  String get title => "$ns.title".tr();

  String get screenshot => "$ns.screenshot".tr();

  String get take => "$ns.take".tr();

  String get enableBackground => "$ns.enableBackground.title".tr();

  String get enableBackgroundDesc => "$ns.enableBackground.desc".tr();
}

class _Import {
  const _Import();

  static const ns = "${_I18n.ns}.import";

  String get title => "$ns.title".tr();

  String get import => "$ns.import".tr();

  String get fromFile => "$ns.fromFile".tr();

  String get fromFileBtn => "$ns.fromFileBtn".tr();

  String get connectivityCheckerDesc => "$ns.connectivityCheckerDesc".tr();

  String get selectSemesterTip => "$ns.selectSemesterTip".tr();

  String get endTip => "$ns.endTip".tr();

  String get failed => "$ns.failed".tr();

  String get failedDesc => "$ns.failedDesc".tr();

  String get failedTip => "$ns.failedTip".tr();

  String get tryImportBtn => "$ns.tryImportBtn".tr();

  String get importing => "$ns.importing".tr();

  String get timetableInfo => "$ns.timetableInfo".tr();

  String defaultName(
    String semester,
    String yearStart,
    String yearEnd,
  ) =>
      "$ns.defaultName".tr(namedArgs: {
        "semester": semester,
        "yearStart": yearStart,
        "yearEnd": yearEnd,
      });
}

class _Editor {
  const _Editor();

  static const ns = "${_I18n.ns}.edit";

  String get name => "$ns.name".tr();

  String get infoTab => "$ns.tab.info".tr();

  String get advancedTab => "$ns.tab.advanced".tr();

  String get editCourse => "$ns.editCourse".tr();

  String get newCourse => "$ns.newCourse".tr();

  String get addCourse => "$ns.addCourse".tr();

  String get repeating => "$ns.repeating".tr();

  String get daysOfWeek => "$ns.daysOfWeek".tr();

  String timeslotsSpanMultiple({
    required String from,
    required String to,
  }) =>
      "$ns.timeslots.multiple".tr(namedArgs: {
        "from": from,
        "to": to,
      });

  String timeslotsSpanSingle(String at) => "$ns.timeslots.single".tr(args: [at]);
}

class _Issue {
  const _Issue();

  static const ns = "${_I18n.ns}.issue";

  String get title => "$ns.title".tr();

  String get resolve => "$ns.resolve".tr();

  String get emptyIssue => "$ns.emptyIssue.title".tr();

  String get emptyIssueDesc => "$ns.emptyIssue.desc".tr();

  String get cbeCourseIssue => "$ns.cbeCourseIssue.title".tr();

  String get cbeCourseIssueDesc => "$ns.cbeCourseIssue.desc".tr();

  String get courseOverlapsIssue => "$ns.courseOverlapsIssue.title".tr();

  String get courseOverlapsIssueDesc => "$ns.courseOverlapsIssue.desc".tr();

  String get patchOutOfRangeIssue => "$ns.patchOutOfRangeIssue.title".tr();

  String get patchOutOfRangeIssueDesc => "$ns.patchOutOfRangeIssue.desc".tr();
}

class _Patch {
  const _Patch();

  static const ns = "${_I18n.ns}.patch";

  String get title => "$ns.title".tr();

  String get prefabs => "$ns.prefabs".tr();

  String get defaultName => "$ns.defaultName".tr();

  String get unpack => "$ns.unpack".tr();

  String get noPatches => "$ns.noPatches".tr();

  String get noPatchesTip => "$ns.noPatchesTip".tr();

  String get patchSetName => "$ns.patchSetName".tr();

  String get editName => "$ns.editName".tr();

  String removeDay(String day) => "$ns.removeDay".tr(namedArgs: {
        "day": day,
      });

  String swapDays(String a, String b) => "$ns.swapDays".tr(namedArgs: {
        "a": a,
        "b": b,
      });

  String copyDay(String source, String target) => "$ns.copyDay".tr(namedArgs: {
        "source": source,
        "target": target,
      });

  String moveDay(String source, String target) => "$ns.moveDay".tr(namedArgs: {
        "source": source,
        "target": target,
      });

  String get moveSource => "$ns.moveSource".tr();

  String get moveTarget => "$ns.moveTarget".tr();

  String get copySource => "$ns.copySource".tr();

  String get copyTarget => "$ns.copyTarget".tr();

  String get swappedDay => "$ns.swappedDay".tr();

  String get removedDay => "$ns.removedDay".tr();
}

class _Export {
  const _Export();

  static const ns = "${_I18n.ns}.export";

  String get title => "$ns.title".tr();

  String get export => "$ns.export".tr();

  String get iOSGetShortcutAction => "$ns.iOSGetShortcutAction".tr();

  String get lessonMode => "$ns.lessonMode.title".tr();

  String get lessonModeMerged => "$ns.lessonMode.merged".tr();

  String get lessonModeMergedTip => "$ns.lessonMode.mergedTip".tr();

  String get lessonModeSeparate => "$ns.lessonMode.separate".tr();

  String get lessonModeSeparateTip => "$ns.lessonMode.separateTip".tr();

  String get enableAlarm => "$ns.enableAlarm.title".tr();

  String get enableAlarmDesc => "$ns.enableAlarm.desc".tr();

  String get alarmMode => "$ns.alarmMode.title".tr();

  String get alarmModeSound => "$ns.alarmMode.sound".tr();

  String get alarmModeDisplay => "$ns.alarmMode.display".tr();

  String get alarmDuration => "$ns.alarmDuration".tr();

  String get alarmBeforeClassBegins => "$ns.alarmBeforeClassBegins.title".tr();

  String alarmBeforeClassBeginsDesc(Duration duration) => "$ns.alarmBeforeClassBegins.desc".tr(namedArgs: {
        "duration": i18n.time.minuteFormat(duration.inMinutes.toString()),
      });
}

class _FreeTip {
  const _FreeTip();

  static const ns = "${_I18n.ns}.freeTip";

  String get dayTip => "$ns.dayTip".tr();

  String get isTodayTip => "$ns.isTodayTip".tr();

  String get weekTip => "$ns.weekTip".tr();

  String get isThisWeekTip => "$ns.isThisWeekTip".tr();

  String get termTip => "$ns.termTip".tr();

  String get findNearestWeekWithClass => "$ns.findNearestWeekWithClass".tr();

  String get findNearestDayWithClass => "$ns.findNearestDayWithClass".tr();
}

class _Settings {
  const _Settings();

  static const ns = "${_I18n.ns}.settings";

  String get autoUseImported => "$ns.autoUseImported.title".tr();

  String get autoUseImportedDesc => "$ns.autoUseImported.desc".tr();

  String get palette => "$ns.palette.title".tr();

  String get paletteDesc => "$ns.palette.desc".tr();

  String get cellStyle => "$ns.cellStyle.title".tr();

  String get cellStyleDesc => "$ns.cellStyle.desc".tr();

  String get background => "$ns.background.title".tr();

  String get backgroundDesc => "$ns.background.desc".tr();

  String get quickLookLessonOnTap => "$ns.quickLookLessonOnTap.title".tr();

  String get quickLookLessonOnTapDesc => "$ns.quickLookLessonOnTap.desc".tr();
}
