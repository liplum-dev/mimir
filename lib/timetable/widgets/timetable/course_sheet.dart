import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/widgets/card.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/l10n/time.dart';
import 'package:text_scroll/text_scroll.dart';
import '../../entity/timetable_entity.dart';

import '../../i18n.dart';
import '../../entity/timetable.dart';

class TimetableCourseSheetPage extends StatelessWidget {
  final String courseCode;
  final SitTimetableEntity timetable;
  final int? highlightedCourseKey;

  /// A course may include both practical and theoretical parts.
  /// Since the system doesn't support this kind of setting,
  /// the actual teaching system will split them in the processing,
  /// but their course names and course codes are stored in the same way.
  const TimetableCourseSheetPage({
    super.key,
    required this.courseCode,
    required this.timetable,
    this.highlightedCourseKey,
  });

  @override
  Widget build(BuildContext context) {
    final courses = timetable.getCoursesByCourseCode(courseCode);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: TextScroll(
              courses[0].courseName,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverToBoxAdapter(
              child: buildTable(courses),
            ),
          ),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList.builder(
              itemCount: courses.length,
              itemBuilder: (ctx, i) {
                final course = courses[i];
                if (highlightedCourseKey == null) {
                  return CourseDescTile(
                    course,
                    campus: timetable.campus,
                  ).inFilledCard();
                } else if (course.courseKey == highlightedCourseKey) {
                  return CourseDescTile(
                    course,
                    campus: timetable.campus,
                    selected: true,
                  ).inFilledCard();
                } else {
                  return CourseDescTile(
                    course,
                    campus: timetable.campus,
                  ).inOutlinedCard();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTable(List<SitCourse> courses) {
    final teachers = courses.expand((course) => course.teachers).toSet();
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(children: [
          i18n.course.courseCode.text(),
          courseCode.text(),
        ]),
        TableRow(children: [
          i18n.course.classCode.text(),
          courses[0].classCode.text(),
        ]),
        if (teachers.isNotEmpty)
          TableRow(children: [
            i18n.course.teacher(teachers.length).text(),
            teachers.join(", ").text(),
          ]),
      ],
    );
  }
}

class CourseDescTile extends StatelessWidget {
  final SitCourse course;
  final Campus campus;
  final bool selected;

  const CourseDescTile(
    this.course, {
    super.key,
    this.selected = false,
    required this.campus,
  });

  @override
  Widget build(BuildContext context) {
    final weekNumbers = course.weekIndices.l10n();
    final (:begin, :end) = course.calcBeginEndTimePoint(campus);
    return ListTile(
      isThreeLine: true,
      selected: selected,
      title: course.place.text(),
      subtitle: [
        "${Weekday.fromIndex(course.dayIndex).l10n()} ${begin.l10n(context)}–${end.l10n(context)}".text(),
        if (course.teachers.length > 1) course.teachers.join(", ").text(),
        ...weekNumbers.map((n) => n.text()),
      ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.start),
      trailing: course.teachers.length == 1 ? course.teachers.first.text() : null,
    );
  }
}
