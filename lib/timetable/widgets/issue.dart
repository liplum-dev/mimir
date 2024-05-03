import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/design/widgets/expansion_tile.dart';
import 'package:sit/l10n/time.dart';

import '../entity/timetable.dart';
import '../entity/issue.dart';
import '../page/edit/course_editor.dart';
import '../i18n.dart';

extension TimetableIssuesX on List<TimetableIssue> {
  List<Widget> build({
    required BuildContext context,
    required SitTimetable timetable,
    required ValueChanged<SitTimetable> onTimetableChanged,
  }) {
    final emptyIssues = whereType<TimetableEmptyIssue>().toList();
    final cbeIssues = whereType<TimetableCbeIssue>().toList();
    final courseOverlapIssues = whereType<TimetableCourseOverlapIssue>().toList();
    return [
      if (emptyIssues.isNotEmpty)
        TimetableEmptyIssueWidget(
          issues: emptyIssues,
        ),
      if (cbeIssues.isNotEmpty)
        TimetableCbeIssueWidget(
          issues: cbeIssues,
          timetable: timetable,
          onTimetableChanged: onTimetableChanged,
        ),
      if (courseOverlapIssues.isNotEmpty)
        TimetableCourseOverlapIssueWidget(
          issues: courseOverlapIssues,
          timetable: timetable,
          onTimetableChanged: onTimetableChanged,
        ),
    ];
  }
}

class TimetableEmptyIssueWidget extends StatefulWidget {
  final List<TimetableEmptyIssue> issues;

  const TimetableEmptyIssueWidget({
    super.key,
    required this.issues,
  });

  @override
  State<TimetableEmptyIssueWidget> createState() => _TimetableEmptyIssueWidgetState();
}

class _TimetableEmptyIssueWidgetState extends State<TimetableEmptyIssueWidget> {
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        title: i18n.issue.emptyIssue.text(),
        subtitle: i18n.issue.emptyIssueDesc.text(),
      ),
    );
  }
}

class TimetableCbeIssueWidget extends StatefulWidget {
  final List<TimetableCbeIssue> issues;
  final SitTimetable timetable;
  final ValueChanged<SitTimetable> onTimetableChanged;

  const TimetableCbeIssueWidget({
    super.key,
    required this.issues,
    required this.timetable,
    required this.onTimetableChanged,
  });

  @override
  State<TimetableCbeIssueWidget> createState() => _TimetableCbeIssueWidgetState();
}

class _TimetableCbeIssueWidgetState extends State<TimetableCbeIssueWidget> {
  @override
  Widget build(BuildContext context) {
    final timetable = widget.timetable;
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: AnimatedExpansionTile(
        initiallyExpanded: true,
        title: i18n.issue.cbeCourseIssue.text(),
        subtitle: i18n.issue.cbeCourseIssueDesc.text(),
        children: widget.issues.map((issue) {
          final course = timetable.courses["${issue.courseKey}"]!;
          return ListTile(
            title: course.courseName.text(),
            subtitle: [
              course.place.text(),
            ].column(caa: CrossAxisAlignment.start),
            trailing: PlatformTextButton(
              child: i18n.issue.resolve.text(),
              onPressed: () async {
                final newCourse = await context.showSheet<SitCourse>(
                  (ctx) => SitCourseEditorPage(
                    title: i18n.editor.editCourse,
                    course: course,
                    editable: const SitCourseEditable.only(hidden: true),
                  ),
                );
                if (newCourse == null) return;
                final newTimetable = timetable.copyWith(
                  courses: Map.of(timetable.courses)..["${newCourse.courseKey}"] = newCourse,
                );
                widget.onTimetableChanged(newTimetable);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TimetableCourseOverlapIssueWidget extends StatefulWidget {
  final List<TimetableCourseOverlapIssue> issues;
  final SitTimetable timetable;
  final ValueChanged<SitTimetable> onTimetableChanged;

  const TimetableCourseOverlapIssueWidget({
    super.key,
    required this.issues,
    required this.timetable,
    required this.onTimetableChanged,
  });

  @override
  State<TimetableCourseOverlapIssueWidget> createState() => _TimetableCourseOverlapIssueWidgetState();
}

class _TimetableCourseOverlapIssueWidgetState extends State<TimetableCourseOverlapIssueWidget> {
  @override
  Widget build(BuildContext context) {
    final timetable = widget.timetable;
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: AnimatedExpansionTile(
        initiallyExpanded: true,
        title: i18n.issue.courseOverlapsIssue.text(),
        subtitle: i18n.issue.courseOverlapsIssueDesc.text(),
        children: widget.issues.map((issue) {
          final courses = issue.courseKeys.map((key) => timetable.courses["$key"]).whereType<SitCourse>().toList();
          return ListTile(
            title: courses.map((course) => course.courseName).join(", ").text(),
            subtitle: [
              ...courses.map((course) {
                final (:begin, :end) = calcBeginEndTimePoint(course.timeslots, timetable.campus, course.place);
                return "${Weekday.fromIndex(course.dayIndex).l10n()} ${begin.l10n(context)}–${end.l10n(context)}"
                    .text();
              }),
            ].column(caa: CrossAxisAlignment.start),
          );
        }).toList(),
      ),
    );
  }
}
