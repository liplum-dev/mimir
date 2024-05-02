import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/widgets/card.dart';
import 'package:sit/design/widgets/expansion_tile.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/school/widgets/course.dart';
import 'package:sit/timetable/entity/timetable.dart';
import '../i18n.dart';

class TimetableCourseCard extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final String classCode;
  final Campus campus;
  final List<SitCourse> courses;
  final Color? color;

  const TimetableCourseCard({
    super.key,
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.courses,
    required this.campus,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final allHidden = courses.every((c) => c.hidden);
    final templateStyle = TextStyle(color: allHidden ? context.theme.disabledColor : null);
    return AnimatedExpansionTile(
      leading: CourseIcon(
        courseName: courseName,
        enabled: !allHidden,
      ),
      title: courseName.text(style: templateStyle),
      subtitle: [
        if (courseCode.isNotEmpty) "${i18n.course.courseCode} $courseCode".text(style: templateStyle),
        if (classCode.isNotEmpty) "${i18n.course.classCode} $classCode".text(style: templateStyle),
      ].column(caa: CrossAxisAlignment.start),
      children: courses.map((course) {
        final weekNumbers = course.weekIndices.l10n();
        final (:begin, :end) = course.calcBeginEndTimePoint(campus);
        return ListTile(
          isThreeLine: true,
          enabled: !course.hidden,
          title: course.place.text(),
          trailing: course.teachers.join(", ").text(),
          subtitle: [
            "${Weekday.fromIndex(course.dayIndex).l10n()} ${begin.l10n(context)}–${end.l10n(context)}".text(),
            ...weekNumbers.map((n) => n.text()),
          ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.start),
        );
      }).toList(),
    ).inAnyCard(
      clip: Clip.hardEdge,
      type: allHidden ? CardVariant.outlined : CardVariant.filled,
      color: allHidden ? null : color,
    );
  }
}
