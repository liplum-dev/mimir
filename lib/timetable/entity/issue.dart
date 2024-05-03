import 'package:sit/l10n/time.dart';
import 'package:sit/settings/dev.dart';
import 'package:statistics/statistics.dart';

import 'timetable.dart';
import 'timetable_entity.dart';

sealed class TimetableIssue {}

class TimetableEmptyIssue implements TimetableIssue {
  const TimetableEmptyIssue();
}

/// Credit by Examination
class TimetableCbeIssue implements TimetableIssue {
  final int courseKey;

  const TimetableCbeIssue({
    required this.courseKey,
  });

  static bool detectCbe(SitCourse course) {
    if (course.courseName.contains("自修") || course.courseName.contains("免听")) {
      return true;
    }
    return false;
  }
}

class TimetableCourseOverlapIssue implements TimetableIssue {
  final List<int> courseKeys;
  final int weekIndex;
  final Weekday weekday;
  final ({int start, int end}) timeslots;

  const TimetableCourseOverlapIssue({
    required this.courseKeys,
    required this.weekIndex,
    required this.weekday,
    required this.timeslots,
  });

  bool isSameOne(TimetableCourseOverlapIssue other) {
    if (courseKeys.toSet().equalsElements(other.courseKeys.toSet())) {
      return true;
    }
    return false;
  }
}

extension SitTimetable4IssueX on SitTimetable {
  List<TimetableIssue> inspect() {
    final issues = <TimetableIssue>[];
    // check if empty
    if (courses.isEmpty) {
      issues.add(const TimetableEmptyIssue());
    }

    // check if any cbe
    for (final course in courses.values) {
      if (!course.hidden && TimetableCbeIssue.detectCbe(course)) {
        issues.add(TimetableCbeIssue(
          courseKey: course.courseKey,
        ));
      }
    }

    // TODO: finish overlap issue inspection
    if (Dev.on) {
      final overlaps = <TimetableCourseOverlapIssue>[];
      final entity = resolve();
      for (final day in entity.days) {
        for (var timeslot = 0; timeslot < day.timeslot2LessonSlot.length; timeslot++) {
          final lessonSlot = day.timeslot2LessonSlot[timeslot];
          if (lessonSlot.lessons.length >= 2) {
            final issue = TimetableCourseOverlapIssue(
              courseKeys: lessonSlot.lessons.map((l) => l.course.courseKey).toList(),
              weekIndex: day.weekIndex,
              weekday: day.weekday,
              timeslots: (start: timeslot, end: timeslot),
            );
            if (overlaps.every((overlap) => !overlap.isSameOne(issue))) {
              overlaps.add(issue);
            }
          }
        }
      }
      issues.addAll(overlaps);
    }

    return issues;
  }
}
