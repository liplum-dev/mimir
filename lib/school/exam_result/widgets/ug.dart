import 'package:flutter/material.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/school/exam_result/page/details.ug.dart';
import 'package:sit/school/widgets/course.dart';
import 'package:sit/utils/format.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';
import '../entity/result.ug.dart';

class ExamResultUgTile extends StatelessWidget {
  final ExamResultUg result;
  final VoidCallback? onTap;
  final Widget? iconOverride;
  final bool selected;

  const ExamResultUgTile(
    this.result, {
    super.key,
    this.onTap,
    this.iconOverride,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final score = result.score;
    return ListTile(
      isThreeLine: true,
      selected: selected,
      leading: iconOverride ?? CourseIcon(courseName: result.courseName),
      titleTextStyle: textTheme.titleMedium,
      title: Text(result.courseName),
      subtitleTextStyle: textTheme.bodyMedium,
      subtitle: [
        '${result.examType}'.text(),
        if (result.teachers.isNotEmpty) result.teachers.join(", ").text(),
      ].column(caa: CrossAxisAlignment.start, mas: MainAxisSize.min),
      leadingAndTrailingTextStyle: textTheme.labelSmall?.copyWith(
        fontSize: textTheme.bodyLarge?.fontSize,
        color: result.passed ? null : context.$red$,
      ),
      trailing: score != null ? score.toString().text() : i18n.lessonNotEvaluated.text(),
      onTap: onTap ??
          () async {
            context.show$Sheet$((ctx) => ExamResultUgDetailsPage(result));
          },
    );
  }
}

class ExamResultItemChip extends StatelessWidget {
  final ExamResultItem item;
  final bool selected;

  const ExamResultItemChip(
    this.item, {
    super.key,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemStyle = context.textTheme.labelSmall;
    return Chip(
      elevation: 4,
      labelStyle: selected ? itemStyle?.copyWith(color: context.colorScheme.primary) : itemStyle,
      label: buildItemText(item).text(),
      labelPadding: EdgeInsets.zero,
    );
  }

  String buildItemText(ExamResultItem item) {
    final score = formatWithoutTrailingZeros(item.score);
    if (item.percentage.isEmpty || item.percentage == "0%") {
      return '${item.scoreType}: $score';
    }
    return '${item.scoreType}${item.percentage}: $score';
  }
}

class ExamResultItemChipGroup extends StatelessWidget {
  final List<ExamResultItem> items;
  final bool selected;

  const ExamResultItemChipGroup(
    this.items, {
    super.key,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return items.map((e) => ExamResultItemChip(e)).toList().wrap(spacing: 4);
  }
}
