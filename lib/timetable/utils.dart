import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/files.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/school/entity/school.dart';
import 'package:sanitize_filename/sanitize_filename.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sit/school/utils.dart';
import 'package:sit/timetable/entity/pos.dart';
import 'package:sit/utils/error.dart';
import 'package:sit/utils/ical.dart';
import 'package:sit/utils/permission.dart';
import 'package:sit/utils/strings.dart';
import 'package:universal_platform/universal_platform.dart';
import '../school/exam_result/entity/result.pg.dart';
import 'entity/timetable.dart';

import 'entity/course.dart';
import 'entity/timetable_entity.dart';
import 'dart:math';

import 'i18n.dart';

import 'page/ical.dart';
import 'package:html/parser.dart';

const maxWeekLength = 20;

final Map<String, int> _weekday2Index = {
  '星期一': 0,
  '星期二': 1,
  '星期三': 2,
  '星期四': 3,
  '星期五': 4,
  '星期六': 5,
  '星期日': 6,
};

/// Then the [weekText] could be `1-5周,14周,8-10周(单)`
/// The return value should be
/// ```dart
/// TimetableWeekIndices([
///  TimetableWeekIndex.all(
///    (start: 0, end: 4)
///  ),
///  TimetableWeekIndex.single(
///    13,
///  ),
///  TimetableWeekIndex.odd(
///    (start: 7, end: 9),
///  ),
/// ])
/// ```
TimetableWeekIndices _parseWeekText2RangedNumbers(
  String weekText, {
  required String allSuffix,
  required String oddSuffix,
  required String evenSuffix,
}) {
  final weeks = weekText.split(',');
// Then the weeks should be ["1-5周","14周","8-10周(单)"]
  final indices = <TimetableWeekIndex>[];
  for (final week in weeks) {
    // odd week
    if (week.endsWith(oddSuffix)) {
      final rangeText = week.removeSuffix(oddSuffix);
      final range = rangeFromString(rangeText, number2index: true);
      indices.add(TimetableWeekIndex.odd(range));
    } else if (week.endsWith(evenSuffix)) {
      final rangeText = week.removeSuffix(evenSuffix);
      final range = rangeFromString(rangeText, number2index: true);
      indices.add(TimetableWeekIndex.even(range));
    } else if (week.endsWith(allSuffix)) {
      final numberText = week.removeSuffix(allSuffix);
      final range = rangeFromString(numberText, number2index: true);
      indices.add(TimetableWeekIndex.all(range));
    }
  }
  return TimetableWeekIndices(indices);
}

Campus _parseCampus(String campus) {
  if (campus.contains("徐汇")) {
    return Campus.xuhui;
  } else {
    return Campus.fengxian;
  }
}

SitTimetable parseUndergraduateTimetableFromCourseRaw(
  List<UndergraduateCourseRaw> all, {
  required Campus defaultCampus,
}) {
  final courseKey2Entity = <String, SitCourse>{};
  var counter = 0;
  var campus = defaultCampus;
  for (final raw in all) {
    final courseKey = counter++;
    final weekIndices = _parseWeekText2RangedNumbers(
      mapChinesePunctuations(raw.weekText),
      allSuffix: "周",
      oddSuffix: "周(单)",
      evenSuffix: "周(双)",
    );
    final dayIndex = _weekday2Index[raw.weekDayText];
    assert(dayIndex != null && 0 <= dayIndex && dayIndex < 7, "dayIndex isn't in range [0,6] but $dayIndex");
    if (dayIndex == null || !(0 <= dayIndex && dayIndex < 7)) continue;
    final timeslots = rangeFromString(raw.timeslotsText, number2index: true);
    assert(timeslots.start <= timeslots.end, "${timeslots.start} > ${timeslots.end} actually. ${raw.courseName}");
    campus = _parseCampus(raw.campus);
    final course = SitCourse(
      courseKey: courseKey,
      courseName: mapChinesePunctuations(raw.courseName).trim(),
      courseCode: raw.courseCode.trim(),
      classCode: raw.classCode.trim(),
      place: reformatPlace(mapChinesePunctuations(raw.place)),
      weekIndices: weekIndices,
      timeslots: timeslots,
      courseCredit: double.tryParse(raw.courseCredit) ?? 0.0,
      dayIndex: dayIndex,
      teachers: raw.teachers.split(","),
    );
    courseKey2Entity["$courseKey"] = course;
  }
  final res = SitTimetable(
    courses: courseKey2Entity,
    lastCourseKey: counter,
    name: "",
    campus: campus,
    startDate: DateTime.utc(0),
    schoolYear: 0,
    semester: Semester.term1,
    lastModified: DateTime.now(),
  );
  return res;
}

Duration calcuSwitchAnimationDuration(num distance) {
  final time = sqrt(max(1, distance) * 100000);
  return Duration(milliseconds: time.toInt());
}

Future<SitTimetable?> readTimetableFromPickedFile() async {
  final result = await FilePicker.platform.pickFiles(
      // Cannot limit the extensions. My RedMi phone just reject all files.
      // type: FileType.custom,
      // allowedExtensions: const ["timetable", "json"],
      );
  if (result == null) return null;
  final content = await _readTimetableFi(result.files.single);
  if (content == null) return null;
  final json = jsonDecode(content);
  final timetable = SitTimetable.fromJson(json);
  return timetable;
}

Future<SitTimetable?> readTimetableFromFile(String path) async {
  final file = File(path);
  final content = await file.readAsString();
  final json = jsonDecode(content);
  final timetable = SitTimetable.fromJson(json);
  return timetable;
}

Future<SitTimetable?> readTimetableFromFileWithPrompt(BuildContext context, String path) async {
  try {
    final timetable = await readTimetableFromFile(path);
    return timetable;
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    if (!context.mounted) return null;
    context.showTip(
      title: "Format error",
      desc: "The file isn't supported. Please select a timetable file.",
      primary: i18n.ok,
    );
    return null;
  }
}

Future<SitTimetable?> readTimetableFromPickedFileWithPrompt(BuildContext context) async {
  try {
    final timetable = await readTimetableFromPickedFile();
    return timetable;
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    if (!context.mounted) return null;
    if (error is PlatformException) {
      await showPermissionDeniedDialog(context: context, permission: Permission.storage);
    } else {
      context.showTip(
        title: "Format error",
        desc: "The file isn't supported. Please select a timetable file.",
        primary: i18n.ok,
      );
    }
    return null;
  }
}

Future<String?> _readTimetableFi(PlatformFile fi) async {
  if (kIsWeb) {
    final bytes = fi.bytes;
    if (bytes == null) return null;
    // timetable file should be encoding in utf-8.
    return const Utf8Decoder().convert(bytes.toList());
  } else {
    final path = fi.path;
    if (path == null) return null;
    final file = File(path);
    return await file.readAsString();
  }
}

Future<void> exportTimetableFileAndShare(
  SitTimetable timetable, {
  required BuildContext context,
}) async {
  final content = jsonEncode(timetable.toJson());
  var fileName = "${timetable.name}.timetable";
  if (timetable.signature.isNotEmpty) {
    fileName = "${timetable.signature} $fileName";
  }
  fileName = sanitizeFilename(fileName, replacement: "-");
  final timetableFi = Files.temp.subFile(fileName);
  final sharePositionOrigin = context.getSharePositionOrigin();
  await timetableFi.writeAsString(content);
  await Share.shareXFiles(
    [XFile(timetableFi.path)],
    sharePositionOrigin: sharePositionOrigin,
  );
}

Future<void> exportTimetableAsICalendarAndOpen(
  BuildContext context, {
  required SitTimetableEntity timetable,
  required TimetableICalConfig config,
}) async {
  final name = "${timetable.type.name}, ${context.formatYmdNum(timetable.type.startDate)}";
  final fileName = sanitizeFilename(
    UniversalPlatform.isAndroid ? "$name #${DateTime.now().millisecondsSinceEpoch ~/ 1000}.ics" : "$name.ics",
    replacement: "-",
  );
  final calendarFi = Files.timetable.calendarDir.subFile(fileName);
  final data = convertTimetable2ICal(timetable: timetable, config: config);
  await calendarFi.writeAsString(data);
  await OpenFile.open(calendarFi.path, type: "text/calendar");
}

String convertTimetable2ICal({
  required SitTimetableEntity timetable,
  required TimetableICalConfig config,
}) {
  final calendar = ICal(
    company: 'mysit.life',
    product: 'SIT Life',
    lang: config.locale?.toLanguageTag() ?? "EN",
  );
  final alarm = config.alarm;
  final merged = config.isLessonMerged;
  final added = <SitTimetableLesson>{};
  for (final week in timetable.weeks) {
    for (final day in week.days) {
      for (final lessonSlot in day.timeslot2LessonSlot) {
        for (final part in lessonSlot.lessons) {
          final lesson = part.type;
          if (merged && added.contains(lesson)) {
            continue;
          } else {
            added.add(lesson);
          }
          final course = part.course;
          final teachers = course.teachers.join(', ');
          final startTime = (merged ? lesson.startTime : part.startTime).toUtc();
          final endTime = (merged ? lesson.endTime : part.endTime).toUtc();
          final uid = merged
              ? "${R.appId}.${course.courseCode}.${week.index}.${day.index}.${lesson.startIndex}-${lesson.endIndex}"
              : "${R.appId}.${course.courseCode}.${week.index}.${day.index}.${part.index}";
          // Use UTC
          final event = calendar.addEvent(
            uid: uid,
            summary: course.courseName,
            location: course.place,
            description: teachers,
            comment: teachers,
            start: startTime,
            end: endTime,
          );
          if (alarm != null) {
            final trigger = startTime.subtract(alarm.alarmBeforeClass).toUtc();
            if (alarm.isDisplayAlarm) {
              event.addAlarmDisplay(
                triggerDate: trigger,
                description: "${course.courseName} ${course.place} $teachers",
                repeating: (repeat: 1, duration: alarm.alarmDuration),
              );
            } else {
              event.addAlarmAudio(
                triggerDate: trigger,
                repeating: (repeat: 1, duration: alarm.alarmDuration),
              );
            }
          }
          if (merged) {
            // skip the `lessonParts` loop
            break;
          }
        }
      }
    }
  }
  return calendar.build();
}

List<PostgraduateCourseRaw> parsePostgraduateCourseRawsFromHtml(String timetableHtmlContent) {
  List<List<int>> generateTimetable() {
    List<List<int>> timetable = [];
    for (int i = 0; i < 9; i++) {
      List<int> timeslots = List.generate(14, (index) => -1);
      timetable.add(timeslots);
    }
    return timetable;
  }

  List<PostgraduateCourseRaw> courseList = [];
  List<List<int>> timetable = generateTimetable();
  const mapOfWeekday = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  final courseCodeRegExp = RegExp(r"(.*?)(学硕\d+班|专硕\d+班|\d+班)$");
  final weekTextRegExp = RegExp(r"([\d-]+周(\([^)]*\))?)([\d-]+节)");

  int parseWeekdayCodeFromIndex(int index, int row, {bool isFirst = false, int rowspan = 1}) {
    if (!isFirst) {
      index = index + 1;
    }
    for (int i = 0; i <= index; i++) {
      if (timetable[i][row] != -1 && timetable[i][row] != row) {
        index++;
      }
    }
    for (int r = 0; r < rowspan; r++) {
      timetable[index][row + r] = row;
    }
    return index - 2;
  }

  void processNodes(List nodes, String weekday) {
    if (nodes.length < 5) {
      // 如果节点数量小于 5，不足以构成一个完整的 Course，忽略
      return;
    }

    final locationWithTeacherStr = mapChinesePunctuations(nodes[4].text);
    final locationWithTeacherList = locationWithTeacherStr.split("  ");
    final location = locationWithTeacherList[0];
    final teacher = locationWithTeacherList[1];

    var courseNameWithClassCode = mapChinesePunctuations(nodes[0].text);
    final String courseName;
    final String classCode;
    RegExpMatch? courseNameWithClassCodeMatch = courseCodeRegExp.firstMatch(courseNameWithClassCode);
    if (courseNameWithClassCodeMatch != null) {
      courseName = courseNameWithClassCodeMatch.group(1) ?? "";
      classCode = courseNameWithClassCodeMatch.group(2) ?? "";
    } else {
      courseName = courseNameWithClassCode;
      classCode = "";
    }

    var weekTextWithTimeslotsText = mapChinesePunctuations(nodes[2].text);
    final String weekText;
    final String timeslotsText;
    RegExpMatch? weekTextWithTimeslotsTextMatch = weekTextRegExp.firstMatch(weekTextWithTimeslotsText);
    if (weekTextWithTimeslotsTextMatch != null) {
      weekText = weekTextWithTimeslotsTextMatch.group(1) ?? "";
      timeslotsText = weekTextWithTimeslotsTextMatch.group(3) ?? "";
    } else {
      weekText = "";
      timeslotsText = "";
    }

    final course = PostgraduateCourseRaw(
      courseName: courseName,
      weekDayText: weekday,
      weekText: weekText,
      timeslotsText: timeslotsText,
      teachers: teacher,
      place: location,
      classCode: classCode,
      courseCode: "",
      courseCredit: "",
      creditHour: "",
    );

    courseList.add(course);

    // 移除处理过的节点，继续处理剩余的节点
    nodes.removeRange(0, 7);

    if (nodes.isNotEmpty) {
      processNodes(nodes, weekday);
    }
  }

  final document = parse(timetableHtmlContent);
  final table = document.querySelector('table');
  final trList = table!.querySelectorAll('tr');
  for (var tr in trList) {
    final row = trList.indexOf(tr);
    final tdList = tr.querySelectorAll('td');
    for (var td in tdList) {
      String firstTdContent = tdList[0].text;
      bool isFirst = const ["上午", "下午", "晚上"].contains(firstTdContent);
      if (td.innerHtml.contains("br")) {
        final index = tdList.indexOf(td);
        final rowspan = int.parse(td.attributes["rowspan"] ?? "1");
        int weekdayCode = parseWeekdayCodeFromIndex(index, row, isFirst: isFirst, rowspan: rowspan);
        String weekday = mapOfWeekday[weekdayCode];
        final nodes = td.nodes;
        processNodes(nodes, weekday);
      }
    }
  }
  return courseList;
}

void completePostgraduateCourseRawsFromPostgraduateScoreRaws(
    List<PostgraduateCourseRaw> courseList, List<ExamResultPgRaw> scoreList) {
  var name2Score = <String, ExamResultPgRaw>{};

  for (var score in scoreList) {
    var key = score.courseName.replaceAll(" ", "");
    name2Score[key] = score;
  }

  for (var course in courseList) {
    var key = course.courseName.replaceAll(" ", "");
    var score = name2Score[key];
    if (score != null) {
      course.courseCode = score.courseCode;
      course.courseCredit = score.credit;
    }
  }
}

SitTimetable parsePostgraduateTimetableFromCourseRaw(
  List<PostgraduateCourseRaw> all, {
  required Campus defaultCampus,
}) {
  final courseKey2Entity = <String, SitCourse>{};
  var counter = 0;
  for (final raw in all) {
    final courseKey = counter++;
    final weekIndices = _parseWeekText2RangedNumbers(
      mapChinesePunctuations(raw.weekText),
      allSuffix: "周",
      oddSuffix: "周(单周)",
      evenSuffix: "周(双周)",
    );
    final dayIndex = _weekday2Index[raw.weekDayText];
    assert(dayIndex != null && 0 <= dayIndex && dayIndex < 7, "dayIndex isn't in range [0,6] but $dayIndex");
    if (dayIndex == null || !(0 <= dayIndex && dayIndex < 7)) continue;
    final timeslotsText = raw.timeslotsText.endsWith("节")
        ? raw.timeslotsText.substring(0, raw.timeslotsText.length - 1)
        : raw.timeslotsText;
    final timeslots = rangeFromString(timeslotsText, number2index: true);
    assert(timeslots.start <= timeslots.end, "${timeslots.start} > ${timeslots.end} actually. ${raw.courseName}");
    final course = SitCourse(
      courseKey: courseKey,
      courseName: mapChinesePunctuations(raw.courseName).trim(),
      courseCode: raw.courseCode.trim(),
      classCode: raw.classCode.trim(),
      place: reformatPlace(mapChinesePunctuations(raw.place)),
      weekIndices: weekIndices,
      timeslots: timeslots,
      courseCredit: double.tryParse(raw.courseCredit) ?? 0.0,
      dayIndex: dayIndex,
      teachers: raw.teachers.split(","),
    );
    courseKey2Entity["$courseKey"] = course;
  }
  final res = SitTimetable(
    courses: courseKey2Entity,
    lastCourseKey: counter,
    name: "",
    campus: defaultCampus,
    startDate: DateTime.utc(0),
    schoolYear: 0,
    semester: Semester.term1,
    lastModified: DateTime.now(),
  );
  return res;
}

Future<int?> selectWeekInTimetable({
  required BuildContext context,
  required SitTimetable timetable,
  int? initialWeekIndex,
  required String submitLabel,
}) async {
  final todayPos = timetable.locate(DateTime.now());
  final todayIndex = todayPos.weekIndex;
  final controller = FixedExtentScrollController(initialItem: initialWeekIndex ?? todayIndex);
  final selectedWeek = await context.showPicker(
        count: 20,
        controller: controller,
        ok: submitLabel,
        okEnabled: (curSelected) => curSelected != initialWeekIndex,
        actions: [
          (ctx, curSelected) => PlatformTextButton(
                onPressed: (curSelected == todayIndex)
                    ? null
                    : () {
                        controller.animateToItem(todayIndex,
                            duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
                      },
                child: i18n.findToday.text(),
              )
        ],
        make: (ctx, i) {
          return Text(i18n.weekOrderedName(number: i + 1));
        },
      ) ??
      initialWeekIndex;
  controller.dispose();
  return selectedWeek;
}

Future<TimetablePos?> selectDayInTimetable({
  required BuildContext context,
  required SitTimetable timetable,
  TimetablePos? initialPos,
  required String submitLabel,
}) async {
  final initialWeekIndex = initialPos?.weekIndex;
  final initialDayIndex = initialPos?.weekday.index;
  final todayPos = timetable.locate(DateTime.now());
  final todayWeekIndex = todayPos.weekIndex;
  final todayDayIndex = todayPos.weekday.index;
  final $week = FixedExtentScrollController(initialItem: initialPos?.weekIndex ?? todayWeekIndex);
  final $day = FixedExtentScrollController(initialItem: initialDayIndex ?? todayDayIndex);
  final (selectedWeek, selectedDay) = await context.showDualPicker(
        countA: 20,
        countB: 7,
        controllerA: $week,
        controllerB: $day,
        ok: submitLabel,
        okEnabled: (weekSelected, daySelected) => weekSelected != initialWeekIndex || daySelected != initialDayIndex,
        actions: [
          (ctx, week, day) => PlatformTextButton(
                onPressed: (week == todayWeekIndex && day == todayDayIndex)
                    ? null
                    : () {
                        $week.animateToItem(todayWeekIndex,
                            duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);

                        $day.animateToItem(todayDayIndex,
                            duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
                      },
                child: i18n.findToday.text(),
              )
        ],
        makeA: (ctx, i) => i18n.weekOrderedName(number: i + 1).text(),
        makeB: (ctx, i) => Weekday.fromIndex(i).l10n().text(),
      ) ??
      (initialWeekIndex, initialDayIndex);
  $week.dispose();
  $day.dispose();
  return selectedWeek != null && selectedDay != null
      ? TimetablePos(weekIndex: selectedWeek, weekday: Weekday.fromIndex(selectedDay))
      : null;
}
