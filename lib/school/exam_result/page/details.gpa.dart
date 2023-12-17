import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/widgets/list_tile.dart';
import 'package:sit/design/widgets/navigation.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/school/entity/school.dart';
import 'package:sit/school/exam_result/entity/gpa.dart';
import 'package:sit/school/exam_result/entity/result.ug.dart';
import '../i18n.dart';

class ExamResultGpaItemDetailsPage extends StatefulWidget {
  final ExamResultGpaItem item;

  const ExamResultGpaItemDetailsPage(this.item, {super.key});

  @override
  State<ExamResultGpaItemDetailsPage> createState() => _ExamResultDetailsPageState();
}

class _ExamResultDetailsPageState extends State<ExamResultGpaItemDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final result = item.initial;
    final score = result.score;
    final time = result.time;
    final items =
    result.items.where((e) => e.score != null && !(e.scoreType == "总评" && e.score == result.score)).toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            pinned: true,
            title: result.courseName.text(),
          ),
          SliverList.list(children: [
            if (score != null)
              DetailListTile(
                leading: const Icon(Icons.score),
                title: i18n.score,
                subtitle: result.score.toString(),
              )
            else
              PageNavigationTile(
                leading: const Icon(Icons.warning),
                title: i18n.courseNotEval.text(),
                subtitle: i18n.examRequireEvalTip.text(),
                path: '/teacher-eval',
              ),
            DetailListTile(
              leading: const Icon(Icons.class_),
              title: UgExamType.title,
              subtitle: result.examType.toString(),
            ),
            DetailListTile(
              leading: const Icon(Icons.view_timeline_outlined),
              title: i18n.course.semester,
              subtitle: result.semesterInfo.l10n(),
            ),
            if (time != null)
              DetailListTile(
                leading: const Icon(Icons.access_time),
                title: i18n.publishTime,
                subtitle: context.formatYmdhmNum(time),
              ),
            DetailListTile(
              leading: const Icon(Icons.numbers),
              title: i18n.course.courseCode,
              subtitle: result.courseCode.toString(),
            ),
            if (result.classCode.isNotEmpty)
              DetailListTile(
                leading: const Icon(Icons.group),
                title: i18n.course.classCode,
                subtitle: result.classCode.toString(),
              ),
            if (result.courseCat != CourseCat.none)
              DetailListTile(
                leading: const Icon(Icons.category),
                title: i18n.course.courseCategory,
                subtitle: result.courseCat.toString(),
              ),
            if (result.teachers.isNotEmpty)
              DetailListTile(
                leading: Icon(result.teachers.length > 1 ? Icons.people : Icons.person),
                title: i18n.course.teacher(result.teachers.length), // plural
                subtitle: result.teachers.join(", "),
              ),
          ]),
          const SliverToBoxAdapter(
            child: Divider(),
          ),
          SliverGrid.extent(
            maxCrossAxisExtent: 240,
            children: items
                .map((item) => ListTile(
              title: "${item.scoreType} ${item.percentage}".text(),
              subtitle: item.score.toString().text(),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
