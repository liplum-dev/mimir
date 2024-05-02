import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/school/utils.dart';
import 'package:sit/school/entity/timetable.dart';
import 'package:sit/school/widgets/course.dart';
import 'package:sit/timetable/widgets/timetable/course_sheet.dart';
import 'package:sit/timetable/palette.dart';
import 'package:sit/timetable/widgets/free.dart';
import 'package:rettulf/rettulf.dart';

import '../../entity/timetable.dart';
import '../../events.dart';
import '../../entity/timetable_entity.dart';
import '../../utils.dart';
import '../../i18n.dart';
import '../style.dart';
import '../../entity/pos.dart';
import 'header.dart';

class DailyTimetable extends StatefulWidget {
  final SitTimetableEntity timetable;

  final ValueNotifier<TimetablePos> $currentPos;

  @override
  State<StatefulWidget> createState() => DailyTimetableState();

  const DailyTimetable({
    super.key,
    required this.timetable,
    required this.$currentPos,
  });
}

class DailyTimetableState extends State<DailyTimetable> {
  SitTimetableEntity get timetable => widget.timetable;

  TimetablePos get currentPos => widget.$currentPos.value;

  set currentPos(TimetablePos newValue) => widget.$currentPos.value = newValue;

  /// 翻页控制
  late PageController _pageController;

  int pos2PageOffset(TimetablePos pos) => pos.weekIndex * 7 + pos.weekday.index;

  TimetablePos page2Pos(int page) => TimetablePos(weekIndex: page ~/ 7, weekday: Weekday.fromIndex(page % 7));

  late StreamSubscription<JumpToPosEvent> $jumpToPos;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: pos2PageOffset(widget.$currentPos.value))
      ..addListener(() {
        setState(() {
          final page = (_pageController.page ?? 0).round();
          final newPos = page2Pos(page);
          if (currentPos != newPos) {
            currentPos = newPos;
          }
        });
      });
    $jumpToPos = eventBus.on<JumpToPosEvent>().listen((event) {
      jumpTo(event.where);
    });
  }

  @override
  void dispose() {
    $jumpToPos.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return [
      widget.$currentPos >>
          (ctx, cur) => TimetableHeader(
                selectedWeekday: cur.weekday,
                weekIndex: cur.weekIndex,
                startDate: timetable.type.startDate,
                onDayTap: (dayIndex) {
                  eventBus.fire(JumpToPosEvent(TimetablePos(weekIndex: cur.weekIndex, weekday: dayIndex)));
                },
              ),
      PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: 20 * 7,
        itemBuilder: (_, int index) {
          int weekIndex = index ~/ 7;
          int dayIndex = index % 7;
          final todayPos = timetable.type.locate(DateTime.now());
          return TimetableOneDayPage(
            timetable: timetable,
            todayPos: todayPos,
            weekIndex: weekIndex,
            weekday: Weekday.fromIndex(dayIndex),
          );
        },
      ).expanded(),
    ].column();
  }

  void jumpTo(TimetablePos pos) {
    if (_pageController.hasClients) {
      final targetOffset = pos2PageOffset(pos);
      final currentPos = _pageController.page ?? targetOffset;
      final distance = (targetOffset - currentPos).abs();
      _pageController.animateToPage(
        targetOffset,
        duration: calcuSwitchAnimationDuration(distance),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }
}

class TimetableOneDayPage extends StatefulWidget {
  final SitTimetableEntity timetable;
  final TimetablePos todayPos;
  final int weekIndex;
  final Weekday weekday;

  const TimetableOneDayPage({
    super.key,
    required this.timetable,
    required this.todayPos,
    required this.weekIndex,
    required this.weekday,
  });

  @override
  State<TimetableOneDayPage> createState() => _TimetableOneDayPageState();
}

class _TimetableOneDayPageState extends State<TimetableOneDayPage> with AutomaticKeepAliveClientMixin {
  Widget? _cached;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cached = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cache = _cached;
    if (cache != null) {
      return cache;
    } else {
      final res = buildPage(context);
      _cached = res;
      return res;
    }
  }

  Widget buildPage(BuildContext ctx) {
    int weekIndex = widget.weekIndex;
    final week = widget.timetable.weeks[weekIndex];
    final day = week[widget.weekday];
    if (!day.hasAnyLesson()) {
      return FreeDayTip(
        timetable: widget.timetable,
        weekIndex: weekIndex,
        weekday: widget.weekday,
      ).scrolled().center();
    } else {
      final slotCount = day.timeslot2LessonSlot.length;
      final builder = _LessonRowBuilder(
        dividerBuilder: (dividerNumber) {
          return BreakDivider(title: dividerNumber == 1 ? i18n.lunchtime : i18n.dinnertime);
        },
      );
      for (int timeslot = 0; timeslot < slotCount; timeslot++) {
        builder.add(
          timeslot,
          buildLessonsInTimeslot(
            ctx,
            day.timeslot2LessonSlot[timeslot].lessons,
            timeslot,
          ),
        );
      }
      // Since the course list is small, no need to use [ListView.builder].
      return ListView(
        children: builder.build(),
      );
    }
  }

  Widget? buildLessonsInTimeslot(
    BuildContext ctx,
    List<SitTimetableLessonPart> lessonsInSlot,
    int timeslot,
  ) {
    if (lessonsInSlot.isEmpty) {
      return null;
    } else if (lessonsInSlot.length == 1) {
      final lesson = lessonsInSlot[0];
      return buildSingleLesson(
        ctx,
        timetable: widget.timetable,
        lesson: lesson,
        timeslot: timeslot,
      ).padH(6);
    } else {
      return LessonOverlapGroup(lessonsInSlot, timeslot, widget.timetable).padH(6);
    }
  }

  Widget buildSingleLesson(
    BuildContext context, {
    required SitTimetableEntity timetable,
    required SitTimetableLessonPart lesson,
    required int timeslot,
  }) {
    final course = lesson.course;
    final style = TimetableStyle.of(context);

    var color = timetable.resolveColor(style.platte, course).byTheme(context.theme);
    color = style.cellStyle.decorateColor(
      color,
      themeColor: context.colorScheme.primary,
      isLessonTaken: lesson.endTime.isBefore(DateTime.now()),
    );
    final classTime = course.buildingTimetableOf(timetable.campus)[timeslot];
    return [
      ClassTimeCard(
        color: color,
        classTime: classTime,
      ),
      LessonCard(
        lesson: lesson,
        timetable: timetable,
        course: course,
        color: color,
      ).expanded()
    ].row();
  }

  @override
  bool get wantKeepAlive => true;
}

class BreakDivider extends StatelessWidget {
  final String title;

  const BreakDivider({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return [
      const Divider(thickness: 2).expanded(),
      title.text().padH(16),
      const Divider(thickness: 2).expanded(),
    ].row();
  }
}

class LessonCard extends StatelessWidget {
  final SitTimetableLessonPart lesson;
  final SitCourse course;
  final SitTimetableEntity timetable;
  final Color color;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.course,
    required this.timetable,
    required this.color,
  });

  static const iconSize = 45.0;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.all(8),
      color: color,
      clipBehavior: Clip.hardEdge,
      child: ListTile(
        leading: CourseIcon(courseName: course.courseName),
        onTap: () async {
          if (!context.mounted) return;
          await context.showSheet(
            (ctx) => TimetableCourseSheetPage(
              courseCode: course.courseCode,
              timetable: timetable,
              highlightedCourseKey: course.courseKey,
            ),
          );
        },
        title: AutoSizeText(
          course.courseName,
          maxLines: 1,
        ),
        subtitle: [
          if (course.place.isNotEmpty)
            Text(beautifyPlace(course.place), softWrap: true, overflow: TextOverflow.ellipsis),
          course.teachers.join(', ').text(),
        ].column(caa: CrossAxisAlignment.start),
      ),
    );
  }
}

class ClassTimeCard extends StatelessWidget {
  final Color color;
  final ClassTime classTime;

  const ClassTimeCard({
    super.key,
    required this.color,
    required this.classTime,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedText(
      color: color,
      margin: 10,
      child: [
        classTime.begin.l10n(context).text(style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        classTime.end.l10n(context).text(),
      ].column(),
    );
  }
}

class LessonOverlapGroup extends StatelessWidget {
  final List<SitTimetableLessonPart> lessonsInSlot;
  final int timeslot;
  final SitTimetableEntity timetable;

  const LessonOverlapGroup(
    this.lessonsInSlot,
    this.timeslot,
    this.timetable, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (lessonsInSlot.isEmpty) return const SizedBox();
    final List<Widget> all = [];
    ClassTime? classTime;
    for (int lessonIndex = 0; lessonIndex < lessonsInSlot.length; lessonIndex++) {
      final lesson = lessonsInSlot[lessonIndex];
      final course = lesson.course;
      final color = timetable.resolveColor(TimetableStyle.of(context).platte, course).byTheme(context.theme);
      classTime = course.buildingTimetableOf(timetable.campus)[timeslot];
      final row = LessonCard(
        lesson: lesson,
        course: course,
        timetable: timetable,
        color: color,
      );
      all.add(row);
    }
    // [classTime] must be nonnull.
    // TODO: Color for class overlap.
    return Card.outlined(
      child: [
        ClassTimeCard(
          color: TimetableStyle.of(context).platte.colors[0].byTheme(context.theme),
          classTime: classTime!,
        ),
        all.column().expanded(),
      ].row().padAll(3),
    );
  }
}

enum _RowBuilderState {
  row,
  divider,
  none;
}

class _LessonRowBuilder {
  final Widget Function(int dividerNumber) dividerBuilder;

  _LessonRowBuilder({required this.dividerBuilder});

  final List<Widget> _rows = [];
  _RowBuilderState lastAdded = _RowBuilderState.none;

  void add(int index, Widget? row) {
    // WOW! MEAL TIME!
    // For each four classes, there's a meal.
    // Avoid adding two divider in a row
    if (index != 0 && index % 4 == 0 && lastAdded != _RowBuilderState.divider) {
      _rows.add(dividerBuilder(index ~/ 4));
      lastAdded = _RowBuilderState.divider;
    }
    if (row != null) {
      _rows.add(row);
      lastAdded = _RowBuilderState.row;
    }
  }

  List<Widget> build() {
    // Remove surplus dividers.
    for (int i = _rows.length - 1; 0 <= i; i--) {
      if (_rows[i] is Divider) {
        _rows.removeLast();
      } else {
        break;
      }
    }
    return _rows;
  }
}

class ElevatedText extends StatelessWidget {
  final Widget child;
  final Color color;
  final double margin;

  const ElevatedText({
    super.key,
    required this.color,
    required this.margin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: color,
      child: child.padAll(margin),
    );
  }
}
