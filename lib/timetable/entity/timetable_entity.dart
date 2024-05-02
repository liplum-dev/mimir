import 'dart:async';
import 'dart:collection';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/school/entity/school.dart';
import 'package:sit/school/entity/timetable.dart';
import 'package:sit/school/utils.dart';
import 'package:sit/timetable/utils.dart';
import 'package:collection/collection.dart';
import 'package:sit/utils/date.dart';
import 'package:sit/utils/entity_node.dart';
import 'patch.dart';
import 'platte.dart';
import 'timetable.dart';

part 'timetable_entity.g.dart';

class SitTimetableEntityState {
  final SitTimetable type;

  const SitTimetableEntityState({required this.type});
}

/// The entity to display.
class SitTimetableEntity
    with SitTimetablePaletteResolver, EntityNodeBase<SitTimetableEntityState>, CourseCodeIndexer
    implements EntityNode<SitTimetableEntityState> {
  @override
  final EntityNode? parent = null;

  @override
  Iterable<SitCourse> get courses => type.courses.values;

  @override
  List<SitTimetableDay> get children => days;

  /// The Default number of weeks is 20 * 7.
  final List<SitTimetableDay> days = [];

  List<SitTimetableWeek> get weeks => List.generate(maxWeekLength, (index) => getWeek(index));

  SitTimetableEntity();

  @override
  SitTimetable get type => state.type;

  SitTimetableWeek getWeek(int weekIndex) {
    return SitTimetableWeek(days.sublist(weekIndex * 7, weekIndex * 7 + 7));
  }

  SitTimetableDay getDay(int weekIndex, Weekday weekday) {
    return days[weekIndex * 7 + weekday.index];
  }

  @override
  void build() {
    days.clear();
    days.addAll(List.generate(
        maxWeekLength * 7,
        (index) => SitTimetableDay(
              weekIndex: index ~/ 7,
              weekday: Weekday.fromIndex(index % 7),
            )..parent = this));
    super.build();
  }

  @override
  void onStateChange(SitTimetableEntityState? oldState, SitTimetableEntityState newState) {
    // travelEvent(
    //   EntityNodeStateChangeEvent(
    //     source: this,
    //     oldState: oldState,
    //     newState: newState,
    //   ),
    //   depth: 1,
    // );
    _generateLessons();
  }

  void _generateLessons() {
    final day2Lessons = <SitTimetableDay, List<SitTimetableLesson>>{};
    for (final course in state.type.courses.values) {
      if (course.hidden) continue;
      for (final weekIndex in course.weekIndices.getWeekIndices()) {
        assert(
          0 <= weekIndex && weekIndex < maxWeekLength,
          "Week index is more out of range [0,$maxWeekLength) but $weekIndex.",
        );
        if (0 <= weekIndex && weekIndex < maxWeekLength) {
          final day = getDay(weekIndex, Weekday.fromIndex(course.dayIndex));
          final parts = <SitTimetableLessonPart>[];
          final lesson = SitTimetableLesson(
            course: course,
            parts: parts,
          );
          final lessons = day2Lessons[day] ??= [];
          lessons.add(lesson);
        }
      }
    }
    for (final MapEntry(key: day, value: lessons) in day2Lessons.entries) {
      day.state = SitTimetableDayState(lessons: lessons);
    }
  }

  String get name => type.name;

  DateTime get startDate => type.startDate;

  int get schoolYear => type.schoolYear;

  Semester get semester => type.semester;

  Campus get campus => type.campus;

  String get signature => type.signature;

  SitTimetableDay? getDaySinceStart(int days) {
    if (days > maxWeekLength * 7) return null;
    final weekIndex = days ~/ 7;
    if (weekIndex < 0 || weekIndex >= weeks.length) return null;
    final week = weeks[weekIndex];
    final dayIndex = days % 7 - 1;
    return week.days[dayIndex];
  }

  SitTimetableWeek? getWeekOn(DateTime date) {
    if (startDate.isAfter(date)) return null;
    final diff = date.difference(startDate);
    if (diff.inDays > maxWeekLength * 7) return null;
    final weekIndex = diff.inDays ~/ 7;
    if (weekIndex < 0 || weekIndex >= weeks.length) return null;
    return weeks[weekIndex];
  }

  SitTimetableDay? getDayOn(DateTime date) {
    if (startDate.isAfter(date)) return null;
    final diff = date.difference(startDate);
    if (diff.inDays > maxWeekLength * 7) return null;
    final weekIndex = diff.inDays ~/ 7;
    if (weekIndex < 0 || weekIndex >= weeks.length) return null;
    final week = weeks[weekIndex];
    // don't -1 here, because inDays always omitted fraction.
    final dayIndex = diff.inDays % 7;
    return week.days[dayIndex];
  }
}

extension type SitTimetableWeek(List<SitTimetableDay> days) {
  int get index => days.first.weekIndex;

  bool get isFree => days.every((day) => day.isFree);

  SitTimetableDay operator [](Weekday weekday) => days[weekday.index];

  operator []=(Weekday weekday, SitTimetableDay day) => days[weekday.index] = day;
}

@CopyWith(skipFields: true)
class SitTimetableDayState {
  final List<SitTimetableLesson> lessons;

  const SitTimetableDayState({
    required this.lessons,
  });
}

class SitTimetableDay with EntityNodeBase<SitTimetableDayState> implements EntityNode<SitTimetableDayState> {
  @override
  late final SitTimetableEntity parent;

  final int weekIndex;
  final Weekday weekday;

  /// The Default number of lessons in one day is 11. But it can be extended.
  /// For example,
  /// A Timeslot could contain one or more lesson.
  final List<SitTimetableLessonSlot> timeslots = [];

  Set<SitCourse> get associatedCourses =>
      timeslots.map((slot) => slot.lessons).flattened.map((part) => part.course).toSet();

  @override
  List<SitTimetableLessonSlot> get children => timeslots;

  DateTime get date => reflectWeekDayIndexToDate(
        startDate: parent.startDate,
        weekIndex: weekIndex,
        weekday: weekday,
      );

  SitTimetableDay({
    required this.weekIndex,
    required this.weekday,
  });

  @override
  void build() {
    timeslots.clear();
    timeslots.addAll(List.generate(11, (index) => SitTimetableLessonSlot()..parent = this));
    super.build();
  }

  bool get isFree => timeslots.every((lessonSlot) => lessonSlot.lessons.isEmpty);
  bool get hasAnyLesson =>  !isFree;

  void add({required SitTimetableLessonPart lesson, required int at}) {
    assert(0 <= at && at < timeslots.length);
    if (0 <= at && at < timeslots.length) {
      final lessonSlot = timeslots[at];
      lessonSlot.lessons.add(lesson);
      lesson.type.parent = this;
    }
  }

  void clear() {
    for (final lessonSlot in timeslots) {
      lessonSlot.lessons.clear();
    }
  }

  void replaceWith(SitTimetableDay other) {
    // timeslot2LessonSlot
    setLessonSlots(other.cloneLessonSlots());
  }

  void swap(SitTimetableDay other) {
    // timeslot2LessonSlot
    final $timeslot2LessonSlot = other.cloneLessonSlots();
    other.setLessonSlots(cloneLessonSlots());
    setLessonSlots($timeslot2LessonSlot);
  }

  void setLessonSlots(Iterable<SitTimetableLessonSlot> v) {
    timeslots.clear();
    timeslots.addAll(v);

    for (final lessonSlot in timeslots) {
      lessonSlot.parent = this;
      for (final part in lessonSlot.lessons) {
        part.type.parent = this;
      }
    }
  }

  List<SitTimetableLessonSlot> cloneLessonSlots() {
    return [];
  }

  /// At all lessons [layer]
  Iterable<SitTimetableLessonPart> browseLessonsAt({required int layer}) sync* {
    for (final lessonSlot in timeslots) {
      if (0 <= layer && layer < lessonSlot.lessons.length) {
        yield lessonSlot.lessons[layer];
      }
    }
  }

  @override
  String toString() {
    return "${_formatDay(date)} [$weekIndex-${weekday.index}] $timeslots";
  }
}

class SitTimetableLessonSlotState {
  const SitTimetableLessonSlotState();
}

/// Lessons in the same timeslot.
class SitTimetableLessonSlot
    with EntityNodeBase<SitTimetableLessonSlotState>
    implements EntityNode<SitTimetableLessonSlotState> {
  @override
  late final SitTimetableDay parent;
  final List<SitTimetableLessonPart> lessons = [];

  @override
  List<SitTimetableLessonPart> get children => lessons;

  @override
  void build() {
    lessons.clear();
    super.build();
  }

  SitTimetableLessonPart? lessonAt(int index) {
    return lessons.elementAtOrNull(index);
  }

  @override
  String toString() {
    return "${_formatDay(parent.date)} $lessons".toString();
  }
}

String _formatDay(DateTime date) {
  return "${date.year}/${date.month}/${date.day}";
}

String _formatTime(DateTime date) {
  return "${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}";
}

class SitTimetableLesson {
  late SitTimetableDay parent;

  /// A lesson may last two or more time slots.
  /// If current [SitTimetableLessonPart] is a part of the whole lesson, they all have the same [courseKey].
  final SitCourse course;

  /// in timeslot order
  final List<SitTimetableLessonPart> parts;

  SitTimetableLesson({
    required this.course,
    required this.parts,
  });

  /// How many timeslots this lesson takes.
  /// It's at least 1 timeslot.
  int get timeslotDuration => endIndex - startIndex + 1;

  /// The start index of this lesson in a [SitTimetableWeek]
  int get startIndex => parts.first.index;

  /// The end index of this lesson in a [SitTimetableWeek]
  int get endIndex => parts.last.index;

  DateTime get startTime => parts.first.startTime;

  DateTime get endTime => parts.last.endTime;

  @override
  String toString() {
    return "${course.courseName} ${_formatTime(startTime)} => ${_formatTime(endTime)}";
  }
}

@CopyWith(skipFields: true)
class SitTimetableLessonPartState {
  final int index;
  final SitTimetableLesson type;

  const SitTimetableLessonPartState({
    required this.index,
    required this.type,
  });
}

class SitTimetableLessonPart
    with EntityNodeBase<SitTimetableLessonPartState>
    implements EntityNode<SitTimetableLessonPartState> {
  @override
  late final SitTimetableLessonSlot? parent;

  @override
  final List<EntityNode> children = const [];

  /// The start index of this lesson in a [SitTimetableWeek]

  late SitTimetableDay _dayCache = type.parent;

  ({DateTime start, DateTime end})? _timeCache;

  ({DateTime start, DateTime end}) get time {
    final timeCache = _timeCache;

    if (_dayCache == type.parent && timeCache != null) {
      return timeCache;
    } else {
      final thatDay = type.parent.date;
      final classTime = course.calcBeginEndTimePointOfLesson(type.parent.parent.campus, index);
      _dayCache = type.parent;
      final time = (start: thatDay.addTimePoint(classTime.begin), end: thatDay.addTimePoint(classTime.end));
      _timeCache = time;
      return time;
    }
  }

  DateTime get startTime => time.start;

  DateTime get endTime => time.end;

  SitCourse get course => type.course;

  int get index => state.index;

  SitTimetableLesson get type => state.type;

  SitTimetableLessonPart();

  @override
  String toString() => "[$index] $type";
}

extension SitTimetable4EntityX on SitTimetable {
  SitTimetableEntity resolve() {
    final entity = SitTimetableEntity();
    EntityNode.buildTree(entity);
    entity.state = SitTimetableEntityState(type: this);
    return entity;
    // final weeks = entity.weeks;
    //
    // for (final course in courses.values) {
    //   if (course.hidden) continue;
    //   final timeslots = course.timeslots;
    //   for (final weekIndex in course.weekIndices.getWeekIndices()) {
    //     assert(
    //       0 <= weekIndex && weekIndex < maxWeekLength,
    //       "Week index is more out of range [0,$maxWeekLength) but $weekIndex.",
    //     );
    //     if (0 <= weekIndex && weekIndex < maxWeekLength) {
    //       final week = weeks[weekIndex];
    //       final day = week.days[course.dayIndex];
    //       final parts = <SitTimetableLessonPart>[];
    //       final lesson = SitTimetableLesson(
    //         course: course,
    //         parts: parts,
    //       );
    //       for (int slot = timeslots.start; slot <= timeslots.end; slot++) {
    //         final part = SitTimetableLessonPart(
    //           type: lesson,
    //           index: slot,
    //         );
    //         parts.add(part);
    //         day.add(
    //           at: slot,
    //           lesson: part,
    //         );
    //       }
    //     }
    //   }
    // }
    //
    // void processPatch(TimetablePatchEntry patch) {
    //   if (patch is TimetablePatchSet) {
    //     for (final patch in patch.patches) {
    //       processPatch(patch);
    //     }
    //   } else if (patch is TimetableRemoveDayPatch) {
    //     for (final loc in patch.all) {
    //       final day = loc.resolveDay(entity);
    //       if (day != null) {
    //         day.clear();
    //       }
    //     }
    //   } else if (patch is TimetableMoveDayPatch) {
    //     final source = patch.source;
    //     final target = patch.target;
    //     final sourceDay = source.resolveDay(entity);
    //     final targetDay = target.resolveDay(entity);
    //     if (sourceDay != null && targetDay != null) {
    //       targetDay.replaceWith(sourceDay);
    //       sourceDay.clear();
    //     }
    //   } else if (patch is TimetableCopyDayPatch) {
    //     final source = patch.source;
    //     final target = patch.target;
    //     final sourceDay = source.resolveDay(entity);
    //     final targetDay = target.resolveDay(entity);
    //     if (sourceDay != null && targetDay != null) {
    //       targetDay.replaceWith(sourceDay);
    //     }
    //   } else if (patch is TimetableSwapDaysPatch) {
    //     final a = patch.a;
    //     final b = patch.b;
    //     final aDay = a.resolveDay(entity);
    //     final bDay = b.resolveDay(entity);
    //     if (aDay != null && bDay != null) {
    //       aDay.swap(bDay);
    //     }
    //   }
    // }
    //
    // for (final patch in patches) {
    //   processPatch(patch);
    // }
    //
    // if (kDebugMode) {
    //   for (final week in entity.weeks) {
    //     for (final day in week.days) {
    //       assert(day.parent == week);
    //       for (final slot in day.timeslot2LessonSlot) {
    //         assert(slot.parent == day);
    //         for (final lessonPart in slot.lessons) {
    //           assert(lessonPart.type.parts.contains(lessonPart));
    //           assert(lessonPart.type.startTime.inTheSameDay(day.date));
    //         }
    //       }
    //     }
    //   }
    // }
    // return entity;
  }
}
