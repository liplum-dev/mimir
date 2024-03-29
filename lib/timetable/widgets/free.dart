import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/widgets/common.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/timetable/entity/timetable.dart';
import 'package:rettulf/rettulf.dart';
import '../entity/pos.dart';
import '../events.dart';
import '../i18n.dart';

class FreeDayTip extends StatelessWidget {
  final SitTimetableEntity timetable;
  final int weekIndex;
  final Weekday weekday;

  const FreeDayTip({
    super.key,
    required this.timetable,
    required this.weekIndex,
    required this.weekday,
  });

  @override
  Widget build(BuildContext context) {
    final todayPos = timetable.type.locate(DateTime.now());
    final isToday = todayPos.weekIndex == weekIndex && todayPos.weekday == weekday;
    final String desc;
    if (isToday) {
      desc = i18n.freeTip.isTodayTip;
    } else {
      desc = i18n.freeTip.dayTip;
    }
    return LeavingBlank(
      icon: Icons.free_cancellation_rounded,
      desc: desc,
      subtitle: PlatformTextButton(
        onPressed: () async {
          await jumpToNearestDayWithClass(context, weekIndex, weekday.index);
        },
        child: i18n.freeTip.findNearestDayWithClass.text(),
      ),
    );
  }

  /// Find the nearest day with class forward.
  /// No need to look back to passed days, unless there's no day after [weekIndex] and [dayIndex] that has any class.
  Future<void> jumpToNearestDayWithClass(
    BuildContext ctx,
    int weekIndex,
    int dayIndex,
  ) async {
    for (int i = weekIndex; i < timetable.weeks.length; i++) {
      final week = timetable.weeks[i];
      if (!week.isFree()) {
        final dayIndexStart = weekIndex == i ? dayIndex : 0;
        for (int j = dayIndexStart; j < week.days.length; j++) {
          final day = week.days[j];
          if (day.hasAnyLesson()) {
            eventBus.fire(JumpToPosEvent(TimetablePos(weekIndex: i, weekday: Weekday.fromIndex(j))));
            return;
          }
        }
      }
    }
    // Now there's no class forward, so let's search backward.
    for (int i = weekIndex; 0 <= i; i--) {
      final week = timetable.weeks[i];
      if (!week.isFree()) {
        final dayIndexStart = weekIndex == i ? dayIndex : week.days.length - 1;
        for (int j = dayIndexStart; 0 <= j; j--) {
          final day = week.days[j];
          if (day.hasAnyLesson()) {
            eventBus.fire(JumpToPosEvent(TimetablePos(weekIndex: i, weekday: Weekday.fromIndex(j))));
            return;
          }
        }
      }
    }
    // WHAT? NO CLASS IN THE WHOLE TERM?
    // Alright, let's congratulate them!
    if (!ctx.mounted) return;
    await ctx.showTip(title: i18n.congratulations, desc: i18n.freeTip.termTip, ok: i18n.ok);
  }
}

class FreeWeekTip extends StatelessWidget {
  final SitTimetableEntity timetable;
  final int weekIndex;

  const FreeWeekTip({
    super.key,
    required this.timetable,
    required this.weekIndex,
  });

  @override
  Widget build(BuildContext context) {
    final String desc;
    final todayPos = timetable.type.locate(DateTime.now());
    if (todayPos.weekIndex == weekIndex) {
      desc = i18n.freeTip.isThisWeekTip;
    } else {
      desc = i18n.freeTip.weekTip;
    }
    return LeavingBlank(
      icon: Icons.free_cancellation_rounded,
      desc: desc,
      subtitle: PlatformTextButton(
        onPressed: () async {
          await jumpToNearestWeekWithClass(
            context,
            weekIndex,
            defaultWeekday: Weekday.monday,
          );
        },
        child: i18n.freeTip.findNearestWeekWithClass.text(),
      ),
    );
  }

  /// Find the nearest week with class forward.
  /// No need to look back to passed weeks, unless there's no week after [weekIndex] that has any class.
  Future<void> jumpToNearestWeekWithClass(
    BuildContext ctx,
    int weekIndex, {
    required Weekday defaultWeekday,
  }) async {
    for (int i = weekIndex; i < timetable.weeks.length; i++) {
      final week = timetable.weeks[i];
      if (!week.isFree()) {
        eventBus.fire(JumpToPosEvent(TimetablePos(weekIndex: i, weekday: defaultWeekday)));
        return;
      }
    }
    // Now there's no class forward, so let's search backward.
    for (int i = weekIndex; 0 <= i; i--) {
      final week = timetable.weeks[i];
      if (!week.isFree()) {
        eventBus.fire(JumpToPosEvent(TimetablePos(weekIndex: i, weekday: defaultWeekday)));
        return;
      }
    }
    // WHAT? NO CLASS IN THE WHOLE TERM?
    // Alright, let's congratulate them!
    if (!ctx.mounted) return;
    await ctx.showTip(title: i18n.congratulations, desc: i18n.freeTip.termTip, ok: i18n.ok);
  }
}
