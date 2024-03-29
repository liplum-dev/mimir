import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/school/entity/school.dart';
import 'package:sit/school/entity/timetable.dart';
import 'package:sit/timetable/entity/platte.dart';

import '../utils.dart';

part 'timetable.g.dart';

@JsonSerializable()
@CopyWith(skipFields: true)
class SitTimetable {
  @JsonKey()
  final String name;
  @JsonKey()
  final DateTime startDate;
  @JsonKey()
  final int schoolYear;
  @JsonKey()
  final Semester semester;
  @JsonKey()
  final int lastCourseKey;
  @JsonKey()
  final String signature;

  /// The index is the CourseKey.
  @JsonKey()
  final Map<String, SitCourse> courses;

  @JsonKey()
  final int version;

  const SitTimetable({
    required this.courses,
    required this.lastCourseKey,
    required this.name,
    required this.startDate,
    required this.schoolYear,
    required this.semester,
    this.signature = "",
    this.version = 1,
  });

  SitTimetableEntity resolve() {
    return resolveTimetableEntity(this);
  }

  @override
  String toString() {
    return {
      "name": name,
      "startDate": startDate,
      "schoolYear": schoolYear,
      "semester": semester,
      "signature": signature,
    }.toString();
  }

  factory SitTimetable.fromJson(Map<String, dynamic> json) => _$SitTimetableFromJson(json);

  Map<String, dynamic> toJson() => _$SitTimetableToJson(this);
}

@JsonSerializable()
@CopyWith(skipFields: true)
class SitCourse {
  @JsonKey()
  final int courseKey;
  @JsonKey()
  final String courseName;
  @JsonKey()
  final String courseCode;
  @JsonKey()
  final String classCode;
  @JsonKey(unknownEnumValue: Campus.fengxian)
  final Campus campus;
  @JsonKey()
  final String place;

  @JsonKey()
  final TimetableWeekIndices weekIndices;

  /// e.g.: (start:1, end: 3) means `2nd slot to 4th slot`.
  /// Starts with 0
  @JsonKey()
  final ({int start, int end}) timeslots;
  @JsonKey()
  final double courseCredit;

  /// e.g.: `0` means `Monday`
  /// Starts with 0
  @JsonKey()
  final int dayIndex;
  @JsonKey()
  final List<String> teachers;

  const SitCourse({
    required this.courseKey,
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.campus,
    required this.place,
    required this.weekIndices,
    required this.timeslots,
    required this.courseCredit,
    required this.dayIndex,
    required this.teachers,
  });

  @override
  String toString() => "[$courseKey] $courseName";

  factory SitCourse.fromJson(Map<String, dynamic> json) => _$SitCourseFromJson(json);

  Map<String, dynamic> toJson() => _$SitCourseToJson(this);
}

extension SitCourseEx on SitCourse {
  List<ClassTime> get buildingTimetable => getTeachingBuildingTimetable(campus, place);

  /// Based on [SitCourse.timeslots], compose a full-length class time.
  /// Starts with the first part starts.
  /// Ends with the last part ends.
  ClassTime calcBeginEndTimePoint() {
    final timetable = buildingTimetable;
    final (:start, :end) = timeslots;
    return (begin: timetable[start].begin, end: timetable[end].end);
  }

  List<ClassTime> calcBeginEndTimePointForEachLesson() {
    final timetable = buildingTimetable;
    final (:start, :end) = timeslots;
    final result = <ClassTime>[];
    for (var timeslot = start; timeslot <= end; timeslot++) {
      result.add(timetable[timeslot]);
    }
    return result;
  }

  ClassTime calcBeginEndTimePointOfLesson(int timeslot) {
    final timetable = buildingTimetable;
    return timetable[timeslot];
  }
}

@JsonEnum()
enum TimetableWeekIndexType {
  all,
  odd,
  even;

  String l10nOf(String start, String end) => "timetable.weekIndexType.of.$name".tr(namedArgs: {
        "start": start,
        "end": end,
      });

  String l10n() => "timetable.weekIndexType.$name".tr();

  static String l10nOfSingle(String index) => "timetable.weekIndexType.of.single".tr(args: [index]);
}

@JsonSerializable()
@CopyWith(skipFields: true)
class TimetableWeekIndex {
  @JsonKey()
  final TimetableWeekIndexType type;

  /// Both [start] and [end] are inclusive.
  /// [start] will equal to [end] if it's not ranged.
  @JsonKey()
  final ({int start, int end}) range;

  const TimetableWeekIndex({
    required this.type,
    required this.range,
  });

  const TimetableWeekIndex.all(
    this.range,
  ) : type = TimetableWeekIndexType.all;

  /// [start] will equal to [end].
  const TimetableWeekIndex.single(
    int weekIndex,
  )   : type = TimetableWeekIndexType.all,
        range = (start: weekIndex, end: weekIndex);

  const TimetableWeekIndex.odd(
    this.range,
  ) : type = TimetableWeekIndexType.odd;

  const TimetableWeekIndex.even(
    this.range,
  ) : type = TimetableWeekIndexType.even;

  /// week number start by
  bool match(int weekIndex) {
    return range.start <= weekIndex && weekIndex <= range.end;
  }

  bool get isSingle => range.start == range.end;

  /// convert the index to number.
  /// e.g.: (start: 0, end: 8) => "1–9"
  String l10n() {
    if (isSingle) {
      return TimetableWeekIndexType.l10nOfSingle("${range.start + 1}");
    } else {
      return type.l10nOf("${range.start + 1}", "${range.end + 1}");
    }
  }

  factory TimetableWeekIndex.fromJson(Map<String, dynamic> json) => _$TimetableWeekIndexFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableWeekIndexToJson(this);
}

@JsonSerializable()
class TimetableWeekIndices {
  @JsonKey()
  final List<TimetableWeekIndex> indices;

  const TimetableWeekIndices(this.indices);

  bool match(int weekIndex) {
    for (final index in indices) {
      if (index.match(weekIndex)) return true;
    }
    return false;
  }

  /// Then the [indices] could be ["a1-5", "s14", "o8-10"]
  /// The return value should be:
  /// - `1-5 周, 14 周, 8-10 单周` in Chinese.
  /// - `1-5 wk, 14 wk, 8-10 odd wk`
  List<String> l10n() {
    return indices.map((index) => index.l10n()).toList();
  }

  /// The result, week index, which starts with 0.
  /// e.g.:
  /// ```dart
  /// TimetableWeekIndices([
  ///  TimetableWeekIndex.all(
  ///    (start: 0, end: 4),
  ///  ),
  ///  TimetableWeekIndex.single(
  ///    13,
  ///  ),
  ///  TimetableWeekIndex.odd(
  ///    (start: 7, end: 9),
  ///  ),
  /// ])
  /// ```
  /// return value is {0,1,2,3,4,13,7,9}.
  Set<int> getWeekIndices() {
    final res = <int>{};
    for (final TimetableWeekIndex(:type, :range) in indices) {
      switch (type) {
        case TimetableWeekIndexType.all:
          for (var i = range.start; i <= range.end; i++) {
            res.add(i);
          }
          break;
        case TimetableWeekIndexType.odd:
          for (var i = range.start; i <= range.end; i += 2) {
            if ((i + 1).isOdd) res.add(i);
          }
          break;
        case TimetableWeekIndexType.even:
          for (var i = range.start; i <= range.end; i++) {
            if ((i + 1).isEven) res.add(i);
          }
          break;
      }
    }
    return res;
  }

  factory TimetableWeekIndices.fromJson(Map<String, dynamic> json) => _$TimetableWeekIndicesFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableWeekIndicesToJson(this);
}

/// If [range] is "1-8", the output will be `(start:0, end: 7)`.
/// if [number2index] is true, the [range] will be considered as a number range, which starts with 1 instead of 0.
({int start, int end}) rangeFromString(
  String range, {
  bool number2index = false,
}) {
  if (range.contains("-")) {
// in range of time slots
    final rangeParts = range.split("-");
    final start = int.parse(rangeParts[0]);
    final end = int.parse(rangeParts[1]);
    if (number2index) {
      return (start: start - 1, end: end - 1);
    } else {
      return (start: start, end: end);
    }
  } else {
    final single = int.parse(range);
    if (number2index) {
      return (start: single - 1, end: single - 1);
    } else {
      return (start: single, end: single);
    }
  }
}

String rangeToString(({int start, int end}) range) {
  if (range.start == range.end) {
    return "${range.start}";
  } else {
    return "${range.start}-${range.end}";
  }
}

class SitTimetableEntity with SitTimetablePaletteResolver {
  @override
  final SitTimetable type;

  /// The Default number of weeks is 20.
  final List<SitTimetableWeek> weeks;

  final _courseCode2CoursesCache = <String, List<SitCourse>>{};

  SitTimetableEntity({
    required this.type,
    required this.weeks,
  });

  List<SitCourse> findAndCacheCoursesByCourseCode(String courseCode) {
    final found = _courseCode2CoursesCache[courseCode];
    if (found != null) {
      return found;
    } else {
      final res = <SitCourse>[];
      for (final course in type.courses.values) {
        if (course.courseCode == courseCode) {
          res.add(course);
        }
      }
      _courseCode2CoursesCache[courseCode] = res;
      return res;
    }
  }

  String get name => type.name;

  DateTime get startDate => type.startDate;

  int get schoolYear => type.schoolYear;

  Semester get semester => type.semester;

  String get signature => type.signature;
}

class SitTimetableWeek {
  final int index;

  /// The 7 days in a week
  final List<SitTimetableDay> days;

  SitTimetableWeek({
    required this.index,
    required this.days,
  });

  factory SitTimetableWeek.$7days(int weekIndex) {
    return SitTimetableWeek(
      index: weekIndex,
      days: List.generate(7, (index) => SitTimetableDay.$11slots(index)),
    );
  }

  bool isFree() {
    return days.every((day) => day.isFree());
  }

  @override
  String toString() => "$days";

  SitTimetableDay operator [](Weekday weekday) => days[weekday.index];

  operator []=(Weekday weekday, SitTimetableDay day) => days[weekday.index] = day;
}

/// Lessons in the same Timeslot.
class SitTimetableLessonSlot {
  final List<SitTimetableLessonPart> lessons;

  SitTimetableLessonSlot({required this.lessons});

  SitTimetableLessonPart? lessonAt(int index) {
    return lessons.elementAtOrNull(index);
  }
}

class SitTimetableDay {
  final int index;

  /// The Default number of lesson in one day is 11. But the length of lessons can be more.
  /// When two lessons are overlapped, it can be 12+.
  /// A Timeslot contain one or more lesson.
  final List<SitTimetableLessonSlot> timeslot2LessonSlot;

  SitTimetableDay({
    required this.index,
    required this.timeslot2LessonSlot,
  });

  factory SitTimetableDay.$11slots(int dayIndex) {
    return SitTimetableDay(
      index: dayIndex,
      timeslot2LessonSlot: List.generate(11, (index) => SitTimetableLessonSlot(lessons: [])),
    );
  }

  bool isFree() {
    return timeslot2LessonSlot.every((lessonSlot) => lessonSlot.lessons.isEmpty);
  }

  void add({required SitTimetableLessonPart lesson, required int at}) {
    assert(0 <= at && at < timeslot2LessonSlot.length);
    if (0 <= at && at < timeslot2LessonSlot.length) {
      final lessonSlot = timeslot2LessonSlot[at];
      lessonSlot.lessons.add(lesson);
    }
  }

  /// At all lessons [layer]
  Iterable<SitTimetableLessonPart> browseLessonsAt({required int layer}) sync* {
    for (final lessonSlot in timeslot2LessonSlot) {
      if (0 <= layer && layer < lessonSlot.lessons.length) {
        yield lessonSlot.lessons[layer];
      }
    }
  }

  bool hasAnyLesson() {
    for (final lessonSlot in timeslot2LessonSlot) {
      if (lessonSlot.lessons.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() => "$timeslot2LessonSlot";
}

class SitTimetableLesson {
  /// The start index of this lesson in a [SitTimetableWeek]
  final int startIndex;

  /// The end index of this lesson in a [SitTimetableWeek]
  final int endIndex;
  final DateTime startTime;
  final DateTime endTime;

  /// A lesson may last two or more time slots.
  /// If current [SitTimetableLessonPart] is a part of the whole lesson, they all have the same [courseKey].
  final SitCourse course;

  /// How many timeslots this lesson takes.
  /// It's at least 1 timeslot.
  int get timeslotDuration => endIndex - startIndex + 1;

  SitTimetableLesson({
    required this.course,
    required this.startIndex,
    required this.endIndex,
    required this.startTime,
    required this.endTime,
  });
}

class SitTimetableLessonPart {
  final SitTimetableLesson type;

  /// The start index of this lesson in a [SitTimetableWeek]
  final int index;

  final DateTime startTime;
  final DateTime endTime;

  SitCourse get course => type.course;

  const SitTimetableLessonPart({
    required this.type,
    required this.index,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() => "$course at $index";
}
