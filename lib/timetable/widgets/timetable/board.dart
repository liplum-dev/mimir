import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/timetable/widgets/style.dart';

import '../../entity/display.dart';
import '../../entity/pos.dart';
import '../../entity/timetable_entity.dart';
import 'background.dart';
import 'daily.dart';
import 'weekly.dart';

class TimetableBoard extends StatefulWidget {
  final SitTimetableEntity timetable;

  final ValueNotifier<DisplayMode> $displayMode;

  final ValueNotifier<TimetablePos> $currentPos;

  const TimetableBoard({
    super.key,
    required this.timetable,
    required this.$displayMode,
    required this.$currentPos,
  });

  @override
  State<TimetableBoard> createState() => _TimetableBoardState();
}

class _TimetableBoardState extends State<TimetableBoard> {
  final verticalOffset = ValueNotifier(0.0);

  @override
  Widget build(BuildContext context) {
    final style = TimetableStyle.of(context);
    final background = style.background;
    if (background.enabled) {
      return [
        Positioned.fill(
          child: TimetableBackground(
            background: background,
            verticalOffset: verticalOffset,
          ),
        ),
        buildBoard(),
      ].stack();
    }
    return buildBoard();
  }

  void onVerticalScrollUpdate(DragUpdateDetails details) {
    verticalOffset.value += details.delta.dy  * 0.005;
  }

  Widget buildBoard() {
    final $displayMode = widget.$displayMode;
    final $currentPos = widget.$currentPos;
    final timetable = widget.timetable;
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.axis == Axis.vertical) {
          if (n is ScrollUpdateNotification) {
            final details = n.dragDetails;
            if (details != null) {
              onVerticalScrollUpdate(details);
            }
            print("update: ${n.dragDetails}");
          }
        }
        return true;
      },
      child: $displayMode >>
          (ctx, mode) => AnimatedSwitcher(
                duration: Durations.short4,
                child: mode == DisplayMode.daily
                    ? DailyTimetable(
                        $currentPos: $currentPos,
                        timetable: timetable,
                      )
                    : WeeklyTimetable(
                        $currentPos: $currentPos,
                        timetable: timetable,
                      ),
              ),
    );
  }
}
