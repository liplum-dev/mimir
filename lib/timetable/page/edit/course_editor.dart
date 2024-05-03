import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sit/design/adaptive/editor.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/design/adaptive/swipe.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/utils/save.dart';

import '../../entity/timetable.dart';
import '../../i18n.dart';

class SitCourseEditable {
  final bool courseName;
  final bool courseCode;
  final bool classCode;
  final bool campus;
  final bool place;
  final bool hidden;
  final bool weekIndices;
  final bool timeslots;
  final bool courseCredit;
  final bool dayIndex;
  final bool teachers;

  const SitCourseEditable({
    required this.courseName,
    required this.courseCode,
    required this.classCode,
    required this.campus,
    required this.place,
    required this.hidden,
    required this.weekIndices,
    required this.timeslots,
    required this.courseCredit,
    required this.dayIndex,
    required this.teachers,
  });

  const SitCourseEditable.item({
    this.place = true,
    this.hidden = true,
    this.weekIndices = true,
    this.timeslots = true,
    this.dayIndex = true,
    this.teachers = true,
  })  : courseName = false,
        courseCode = false,
        classCode = false,
        campus = false,
        courseCredit = false;

  const SitCourseEditable.template()
      : courseName = true,
        courseCode = true,
        classCode = true,
        campus = true,
        courseCredit = true,
        place = false,
        hidden = false,
        weekIndices = false,
        timeslots = false,
        dayIndex = false,
        teachers = false;

  const SitCourseEditable.only({
    this.courseName = false,
    this.courseCode = false,
    this.classCode = false,
    this.campus = false,
    this.place = false,
    this.hidden = false,
    this.weekIndices = false,
    this.timeslots = false,
    this.courseCredit = false,
    this.dayIndex = false,
    this.teachers = false,
  });

  const SitCourseEditable.all({
    this.courseName = true,
    this.courseCode = true,
    this.classCode = true,
    this.campus = true,
    this.place = true,
    this.hidden = true,
    this.weekIndices = true,
    this.timeslots = true,
    this.courseCredit = true,
    this.dayIndex = true,
    this.teachers = true,
  });
}

class SitCourseEditorPage extends StatefulWidget {
  final String? title;
  final SitCourse? course;
  final SitCourseEditable editable;

  const SitCourseEditorPage({
    super.key,
    this.title,
    required this.course,
    this.editable = const SitCourseEditable.all(),
  });

  @override
  State<SitCourseEditorPage> createState() => _SitCourseEditorPageState();
}

class _SitCourseEditorPageState extends State<SitCourseEditorPage> {
  late final $courseName = TextEditingController(text: widget.course?.courseName);
  late final $courseCode = TextEditingController(text: widget.course?.courseCode);
  late final $classCode = TextEditingController(text: widget.course?.classCode);
  late final $place = TextEditingController(text: widget.course?.place);
  late var weekIndices = widget.course?.weekIndices ?? const TimetableWeekIndices([]);
  late var timeslots = widget.course?.timeslots ?? (start: 0, end: 0);
  late var courseCredit = widget.course?.courseCredit ?? 0.0;
  late var hidden = widget.course?.hidden ?? false;
  late var dayIndex = widget.course?.dayIndex ?? 0;
  late var teachers = List.of(widget.course?.teachers ?? <String>[]);
  var anyChanged = false;

  void markChanged() => anyChanged |= true;

  @override
  void initState() {
    super.initState();
    $courseName.addListener(() {
      if ($courseName.text != widget.course?.courseName) {
        setState(() => markChanged());
      }
    });
    $courseCode.addListener(() {
      if ($courseCode.text != widget.course?.courseCode) {
        setState(() => markChanged());
      }
    });
    $classCode.addListener(() {
      if ($classCode.text != widget.course?.classCode) {
        setState(() => markChanged());
      }
    });
  }

  @override
  void dispose() {
    $courseName.dispose();
    $courseCode.dispose();
    $classCode.dispose();
    $place.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.editable;
    return PromptSaveBeforeQuitScope(
      changed: anyChanged,
      onSave: onSave,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              title: widget.title?.text(),
              actions: [
                PlatformTextButton(
                  onPressed: onSave,
                  child: i18n.done.text(),
                ),
              ],
            ),
            SliverList.list(children: [
              buildTextField(
                controller: $courseName,
                title: i18n.course.courseName,
                readonly: !editable.courseName,
              ),
              buildTextField(
                controller: $courseCode,
                title: i18n.course.courseCode,
                readonly: !editable.courseName,
              ),
              buildTextField(
                controller: $classCode,
                title: i18n.course.classCode,
                readonly: !editable.courseName,
              ),
              if (editable.place)
                buildTextField(
                  title: i18n.course.place,
                  controller: $place,
                ),
              if (editable.hidden) buildHidden(),
              if (editable.dayIndex)
                buildWeekdays().inCard(
                  clip: Clip.hardEdge,
                ),
              if (editable.timeslots)
                buildTimeslots().inCard(
                  clip: Clip.hardEdge,
                ),
              if (editable.weekIndices)
                buildRepeating().inCard(
                  clip: Clip.hardEdge,
                ),
              if (editable.teachers)
                buildTeachers().inCard(
                  clip: Clip.hardEdge,
                ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildWeekdays() {
    return ListTile(
      title: i18n.editor.daysOfWeek.text(),
      isThreeLine: true,
      subtitle: [
        ...Weekday.values.map(
          (w) => ChoiceChip(
            showCheckmark: false,
            label: w.l10n().text(),
            selected: dayIndex == w.index,
            onSelected: (value) {
              setState(() {
                dayIndex = w.index;
              });
              markChanged();
            },
          ),
        ),
      ].wrap(spacing: 4),
    );
  }

  Widget buildTimeslots() {
    return ListTile(
      title: (timeslots.start == timeslots.end
              ? i18n.editor.timeslotsSpanSingle("${timeslots.start + 1}")
              : i18n.editor.timeslotsSpanMultiple(from: "${timeslots.start + 1}", to: "${timeslots.end + 1}"))
          .text(),
      subtitle: [
        const Icon(Icons.light_mode),
        RangeSlider(
          values: RangeValues(timeslots.start.toDouble(), timeslots.end.toDouble()),
          max: 10,
          divisions: 10,
          labels: RangeLabels(
            "${timeslots.start.round() + 1}",
            "${timeslots.end.round() + 1}",
          ),
          onChanged: (RangeValues values) {
            final newStart = values.start.toInt();
            final newEnd = values.end.toInt();
            if (timeslots.start != newStart || timeslots.end != newEnd) {
              setState(() {
                timeslots = (start: newStart, end: newEnd);
              });
              markChanged();
            }
          },
        ).expanded(),
        const Icon(Icons.dark_mode),
      ].row(mas: MainAxisSize.min),
    );
  }

  Widget buildRepeating() {
    return [
      ListTile(
        title: i18n.editor.repeating.text(),
        trailing: PlatformIconButton(
          icon: Icon(context.icons.add),
          onPressed: () {
            final newIndices = List.of(weekIndices);
            newIndices.add(const TimetableWeekIndex.all((start: 0, end: 1)));
            setState(() {
              weekIndices = TimetableWeekIndices(newIndices);
            });
            markChanged();
          },
        ),
      ),
      ...weekIndices.mapIndexed((i, index) {
        return RepeatingItemEditor(
          childKey: ValueKey(i),
          index: index,
          onChanged: (value) {
            final newIndices = List.of(weekIndices);
            newIndices[i] = value;
            setState(() {
              weekIndices = TimetableWeekIndices(newIndices);
            });
            markChanged();
          },
          onDeleted: () {
            setState(() {
              weekIndices = TimetableWeekIndices(
                List.of(weekIndices)..removeAt(i),
              );
            });
            markChanged();
          },
        );
      })
    ].column();
  }

  Widget buildTeachers() {
    return ListTile(
      title: i18n.course.teacher(2).text(),
      isThreeLine: true,
      trailing: PlatformIconButton(
        icon: Icon(context.icons.add),
        onPressed: () async {
          final newTeacher = await Editor.showStringEditor(
            context,
            desc: i18n.course.teacher(2),
            initial: "",
          );
          if (newTeacher != null && !teachers.contains(newTeacher)) {
            if (!mounted) return;
            setState(() {
              teachers.add(newTeacher);
            });
            markChanged();
          }
        },
      ),
      subtitle: [
        ...teachers.map((teacher) => InputChip(
              label: teacher.text(),
              onDeleted: () {
                setState(() {
                  teachers.remove(teacher);
                });
                markChanged();
              },
            )),
      ].wrap(spacing: 4),
    );
  }

  Widget buildHidden() {
    return ListTile(
      title: i18n.course.displayable.text(),
      trailing: Switch.adaptive(
        value: !hidden,
        onChanged: (newV) {
          setState(() {
            hidden = !newV;
          });
          markChanged();
        },
      ),
    );
  }

  void onSave() {
    context.pop(SitCourse(
      courseKey: widget.course?.courseKey ?? 0,
      courseName: $courseName.text,
      courseCode: $courseCode.text,
      classCode: $classCode.text,
      place: $place.text,
      weekIndices: weekIndices,
      timeslots: timeslots,
      courseCredit: courseCredit,
      dayIndex: dayIndex,
      teachers: teachers,
      hidden: hidden,
    ));
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String title,
    bool readonly = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 1,
      readOnly: readonly,
      decoration: InputDecoration(
        labelText: title,
        enabled: !readonly,
        border: const OutlineInputBorder(),
      ),
    ).padAll(10);
  }
}

class RepeatingItemEditor extends StatelessWidget {
  final Key childKey;
  final TimetableWeekIndex index;
  final ValueChanged<TimetableWeekIndex>? onChanged;
  final void Function()? onDeleted;

  const RepeatingItemEditor({
    super.key,
    required this.index,
    required this.childKey,
    this.onChanged,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final onDeleted = this.onDeleted;
    return WithSwipeAction(
      childKey: childKey,
      right: onDeleted == null
          ? null
          : SwipeAction.delete(
              icon: context.icons.delete,
              action: () async {
                onDeleted();
              },
            ),
      child: ListTile(
        title: index.l10n().text(),
        isThreeLine: true,
        subtitle: [
          RangeSlider(
            values: RangeValues(index.range.start.toDouble(), index.range.end.toDouble()),
            max: 19,
            divisions: 19,
            labels: RangeLabels(
              "${index.range.start.round() + 1}",
              "${index.range.end.round() + 1}",
            ),
            onChanged: (RangeValues values) {
              final newStart = values.start.toInt();
              final newEnd = values.end.toInt();
              if (index.range.start != newStart || index.range.end != newEnd) {
                onChanged?.call(index.copyWith(
                  range: (start: newStart, end: newEnd),
                  type: newStart == newEnd ? TimetableWeekIndexType.all : index.type,
                ));
              }
            },
          ),
          [
            ...TimetableWeekIndexType.values.map((type) => ChoiceChip(
                  label: type.l10n().text(),
                  selected: index.type == type,
                  onSelected: type != TimetableWeekIndexType.all && index.isSingle
                      ? null
                      : (value) {
                          onChanged?.call(index.copyWith(
                            type: type,
                          ));
                        },
                )),
          ].wrap(spacing: 4),
        ].column(mas: MainAxisSize.min, caa: CrossAxisAlignment.start),
      ),
    );
  }
}
