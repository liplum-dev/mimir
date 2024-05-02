import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/design/dash_decoration.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/school/utils.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/timetable/palette.dart';
import 'package:rettulf/rettulf.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../events.dart';
import '../../entity/timetable.dart';
import '../../entity/timetable_entity.dart';
import 'course_sheet.dart';
import '../../utils.dart';
import '../free.dart';
import 'header.dart';
import '../style.dart';
import '../../entity/pos.dart';
import '../../i18n.dart';

class WeeklyTimetable extends StatefulWidget {
  final SitTimetableEntity timetable;

  final ValueNotifier<TimetablePos> $currentPos;

  @override
  State<StatefulWidget> createState() => WeeklyTimetableState();

  const WeeklyTimetable({
    super.key,
    required this.timetable,
    required this.$currentPos,
  });
}

class WeeklyTimetableState extends State<WeeklyTimetable> {
  late PageController pageController;
  final $cellSize = ValueNotifier(Size.zero);

  SitTimetableEntity get timetable => widget.timetable;

  TimetablePos get currentPos => widget.$currentPos.value;

  set currentPos(TimetablePos newValue) => widget.$currentPos.value = newValue;
  late StreamSubscription<JumpToPosEvent> $jumpToPos;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPos.weekIndex)
      ..addListener(() {
        setState(() {
          final newWeek = (pageController.page ?? 0).round();
          if (newWeek != currentPos.weekIndex) {
            currentPos = currentPos.copyWith(weekIndex: newWeek);
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
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (ctx, weekIndex) {
        return TimetableOneWeekCached(
          timetable: timetable,
          weekIndex: weekIndex,
        );
      },
    );
  }

  /// 跳到某一周
  void jumpTo(TimetablePos pos) {
    if (pageController.hasClients) {
      final targetOffset = pos.weekIndex;
      final currentPos = pageController.page ?? targetOffset;
      final distance = (targetOffset - currentPos).abs();
      pageController.animateToPage(
        targetOffset,
        duration: calcuSwitchAnimationDuration(distance),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }
}

class TimetableOneWeekCached extends StatefulWidget {
  final SitTimetableEntity timetable;
  final int weekIndex;

  const TimetableOneWeekCached({
    super.key,
    required this.timetable,
    required this.weekIndex,
  });

  @override
  State<TimetableOneWeekCached> createState() => _TimetableOneWeekCachedState();
}

class _TimetableOneWeekCachedState extends State<TimetableOneWeekCached> with AutomaticKeepAliveClientMixin {
  /// Cache the entire page to avoid expensive rebuilding.
  Widget? _cached;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    _cached = null;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TimetableOneWeekCached oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timetable != oldWidget.timetable) {
      _cached = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cache = _cached;
    if (cache != null) {
      return cache;
    } else {
      final style = TimetableStyle.of(context);
      final now = DateTime.now();
      Widget buildCell({
        required BuildContext context,
        required SitTimetableLessonPart lesson,
        required SitTimetableEntity timetable,
      }) {
        final inClassNow = lesson.type.startTime.isBefore(now) && lesson.type.endTime.isAfter(now);
        final passed = lesson.type.endTime.isBefore(now);
        Widget cell = InteractiveCourseCell(
          lesson: lesson,
          style: style,
          timetable: timetable,
          isLessonTaken: passed,
        );
        if (inClassNow) {
          // cell = Card.outlined(
          //   margin: const EdgeInsets.all(1),
          //   child: cell.padAll(1),
          // );
        }
        return cell;
      }

      final res = LayoutBuilder(
        builder: (context, box) {
          return TimetableOneWeek(
            fullSize: Size(box.maxWidth, box.maxHeight * 1.2),
            timetable: widget.timetable,
            weekIndex: widget.weekIndex,
            showFreeTip: true,
            cellBuilder: buildCell,
          ).scrolled();
        },
      );
      _cached = res;
      return res;
    }
  }
}

class TimetableOneWeek extends StatelessWidget {
  final SitTimetableEntity timetable;
  final int weekIndex;
  final Size fullSize;
  final bool showFreeTip;
  final Widget Function({
    required BuildContext context,
    required SitTimetableLessonPart lesson,
    required SitTimetableEntity timetable,
  }) cellBuilder;

  const TimetableOneWeek({
    super.key,
    required this.timetable,
    required this.weekIndex,
    required this.fullSize,
    required this.cellBuilder,
    this.showFreeTip = false,
  });

  @override
  Widget build(BuildContext context) {
    final todayPos = timetable.type.locate(DateTime.now());
    final cellSize = Size(fullSize.width / 7.62, fullSize.height / 11);
    final timetableWeek = timetable.weeks[weekIndex];

    final view = buildSingleWeekView(
      timetableWeek,
      context: context,
      cellSize: cellSize,
      fullSize: fullSize,
      todayPos: todayPos,
    );
    if (showFreeTip && timetableWeek.isFree) {
      // free week
      return [
        view,
        FreeWeekTip(
          timetable: timetable,
          weekIndex: weekIndex,
        ).padOnly(t: fullSize.height * 0.2),
      ].stack();
    } else {
      return view;
    }
  }

  /// 布局左侧边栏, 显示节次
  Widget buildLeftColumn(BuildContext ctx, Size cellSize) {
    final textStyle = ctx.textTheme.bodyMedium;
    final side = getTimetableBorderSide(ctx);
    final cells = <Widget>[];
    cells.add(SizedBox(
      width: cellSize.width * 0.6,
      child: const EmptyHeaderCellTextBox(),
    ));
    for (var i = 0; i < 11; i++) {
      cells.add(Container(
        decoration: BoxDecoration(
          border: Border(right: side),
        ),
        child: SizedBox.fromSize(
          size: Size(cellSize.width * 0.6, cellSize.height),
          child: (i + 1).toString().text(style: textStyle).center(),
        ),
      ));
    }
    return cells.column();
  }

  Widget buildSingleWeekView(
    SitTimetableWeek timetableWeek, {
    required BuildContext context,
    required Size cellSize,
    required Size fullSize,
    required TimetablePos todayPos,
  }) {
    return List.generate(8, (index) {
      if (index == 0) {
        return buildLeftColumn(context, cellSize);
      } else {
        return _buildCellsByDay(
          context,
          timetableWeek.days[index - 1],
          cellSize,
          todayPos: todayPos,
        );
      }
    }).row();
  }

  /// 构建某一天的那一列格子.
  Widget _buildCellsByDay(
    BuildContext context,
    SitTimetableDay day,
    Size cellSize, {
    required TimetablePos todayPos,
  }) {
    final cells = <Widget>[];
    final weekday = Weekday.fromIndex(day.index);
    cells.add(Container(
      width: cellSize.width,
      decoration: BoxDecoration(
        color: todayPos.weekIndex == weekIndex && todayPos.weekday == weekday
            ? context.colorScheme.secondaryContainer
            : null,
        border: Border(bottom: getTimetableBorderSide(context)),
      ),
      child: HeaderCellTextBox(
        weekIndex: weekIndex,
        weekday: weekday,
        startDate: timetable.type.startDate,
      ),
    ));
    for (int timeslot = 0; timeslot < day.timeslot2LessonSlot.length; timeslot++) {
      final lessonSlot = day.timeslot2LessonSlot[timeslot];

      /// TODO: Multi-layer lesson slot
      final lesson = lessonSlot.lessonAt(0);
      if (lesson == null) {
        cells.add(DashLined(
          top: timeslot != 0,
          bottom: timeslot != day.timeslot2LessonSlot.length - 1,
          child: SizedBox(width: cellSize.width, height: cellSize.height),
        ));
      } else {
        /// TODO: Range checking
        final course = lesson.course;
        cells.add(SizedBox(
          width: cellSize.width,
          height: cellSize.height * lesson.type.timeslotDuration,
          child: cellBuilder(
            context: context,
            lesson: lesson,
            timetable: timetable,
          ),
        ));

        /// Skip to the end
        timeslot = lesson.type.endIndex;
      }
    }

    return cells.column();
  }
}

class InteractiveCourseCell extends ConsumerWidget {
  final SitTimetableLessonPart lesson;
  final SitTimetableEntity timetable;
  final bool isLessonTaken;
  final TimetableStyleData style;

  const InteractiveCourseCell({
    super.key,
    required this.lesson,
    required this.timetable,
    this.isLessonTaken = false,
    required this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickLookLessonOnTap = ref.watch(Settings.timetable.$quickLookLessonOnTap) ?? true;
    if (quickLookLessonOnTap) {
      return InteractiveCourseCellWithTooltip(
        timetable: timetable,
        isLessonTaken: isLessonTaken,
        style: style,
        lesson: lesson,
      );
    }
    final course = lesson.course;
    return StyledCourseCell(
      timetable: timetable,
      course: course,
      isLessonTaken: isLessonTaken,
      style: style,
      innerBuilder: (ctx, child) => InkWell(
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
        child: child,
      ),
    );
  }
}

class InteractiveCourseCellWithTooltip extends StatefulWidget {
  final SitTimetableLessonPart lesson;
  final SitTimetableEntity timetable;
  final bool isLessonTaken;
  final TimetableStyleData style;

  const InteractiveCourseCellWithTooltip({
    super.key,
    required this.lesson,
    required this.timetable,
    this.isLessonTaken = false,
    required this.style,
  });

  @override
  State<InteractiveCourseCellWithTooltip> createState() => _InteractiveCourseCellWithTooltipState();
}

class _InteractiveCourseCellWithTooltipState extends State<InteractiveCourseCellWithTooltip> {
  final $tooltip = GlobalKey<TooltipState>(debugLabel: "tooltip");

  @override
  Widget build(BuildContext context) {
    return StyledCourseCell(
      timetable: widget.timetable,
      course: widget.lesson.course,
      isLessonTaken: widget.isLessonTaken,
      style: widget.style,
      innerBuilder: (ctx, child) => Tooltip(
        key: $tooltip,
        preferBelow: false,
        triggerMode: UniversalPlatform.isDesktop ? TooltipTriggerMode.tap : TooltipTriggerMode.manual,
        message: buildTooltipMessage(),
        textAlign: TextAlign.center,
        child: InkWell(
          onTap: UniversalPlatform.isDesktop
              ? null
              : () async {
                  $tooltip.currentState?.ensureTooltipVisible();
                },
          // onDoubleTap: showDetailsSheet,
          onLongPress: showDetailsSheet,
          child: child,
        ),
      ),
    );
  }

  Future<void> showDetailsSheet() async {
    final course = widget.lesson.course;
    await context.showSheet(
      (ctx) => TimetableCourseSheetPage(
        courseCode: course.courseCode,
        timetable: widget.timetable,
        highlightedCourseKey: course.courseKey,
      ),
    );
  }

  String buildTooltipMessage() {
    final lessons = widget.lesson.course.calcBeginEndTimePointForEachLesson(widget.timetable.campus);
    final lessonTimeTip = lessons.map((time) => "${time.begin.l10n(context)}–${time.end.l10n(context)}").join("\n");
    final course = widget.lesson.course;
    var tooltip = "${i18n.course.courseCode} ${course.courseCode}";
    if (course.classCode.isNotEmpty) {
      tooltip += "\n${i18n.course.classCode} ${course.classCode}";
    }
    tooltip += "\n$lessonTimeTip";
    return tooltip;
  }
}

class CourseCell extends StatelessWidget {
  final String courseName;
  final String place;
  final List<String>? teachers;
  final Widget Function(BuildContext context, Widget child)? innerBuilder;
  final Color color;

  const CourseCell({
    super.key,
    required this.courseName,
    required this.color,
    required this.place,
    this.teachers,
    this.innerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final innerBuilder = this.innerBuilder;
    final info = TimetableSlotInfo(
      courseName: courseName,
      maxLines: context.isPortrait ? 8 : 5,
      place: place,
      teachers: teachers,
      // textColor: color.resolveTextColorForReadability(),
    ).center();
    return Card.filled(
      clipBehavior: Clip.hardEdge,
      color: color,
      margin: const EdgeInsets.all(0.5),
      child: innerBuilder != null ? innerBuilder(context, info) : info,
    );
  }
}

class StyledCourseCell extends StatelessWidget {
  final SitCourse course;
  final SitTimetableEntity timetable;
  final bool isLessonTaken;
  final Widget Function(BuildContext context, Widget child)? innerBuilder;
  final TimetableStyleData style;

  const StyledCourseCell({
    super.key,
    required this.timetable,
    required this.course,
    required this.isLessonTaken,
    required this.style,
    this.innerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    var color = timetable.resolveColor(style.platte, course).byTheme(context.theme);
    color = style.cellStyle.decorateColor(
      color,
      themeColor: context.colorScheme.primary,
      isLessonTaken: isLessonTaken,
    );
    return CourseCell(
      courseName: course.courseName,
      color: color,
      place: course.place,
      teachers: style.cellStyle.showTeachers ? course.teachers : null,
      innerBuilder: innerBuilder,
    );
  }
}

class DashLined extends StatelessWidget {
  final Widget? child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const DashLined({
    super.key,
    this.child,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DashDecoration(
        color: context.colorScheme.onBackground.withOpacity(0.3),
        strokeWidth: 0.5,
        borders: {
          if (right) LinePosition.right,
          if (bottom) LinePosition.bottom,
          if (left) LinePosition.left,
          if (top) LinePosition.top,
        },
      ),
      child: child,
    );
  }
}

class TimetableSlotInfo extends StatelessWidget {
  final String courseName;
  final String place;
  final List<String>? teachers;
  final int maxLines;
  final Color? textColor;

  const TimetableSlotInfo({
    super.key,
    required this.maxLines,
    required this.courseName,
    required this.place,
    this.teachers,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final teachers = this.teachers;
    return AutoSizeText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: courseName,
            style: context.textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
          if (place.isNotEmpty)
            TextSpan(
              text: "\n${beautifyPlace(place)}",
              style: context.textTheme.bodySmall?.copyWith(
                color: textColor,
              ),
            ),
          if (teachers != null)
            TextSpan(
              text: "\n${teachers.join(',')}",
              style: context.textTheme.bodySmall?.copyWith(
                color: textColor,
              ),
            ),
        ],
      ),
      minFontSize: 0,
      stepGranularity: 0.1,
      maxLines: maxLines,
      textAlign: TextAlign.center,
    );
  }
}
