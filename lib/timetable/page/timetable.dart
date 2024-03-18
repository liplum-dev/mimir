import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/adaptive/menu.dart';
import 'package:sit/design/adaptive/multiplatform.dart' as multi;
import 'package:sit/design/widgets/fab.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/timetable/page/screenshot.dart';
import '../entity/display.dart';
import '../events.dart';
import '../i18n.dart';
import '../entity/timetable.dart';
import '../init.dart';
import '../entity/pos.dart';
import '../widgets/focus.dart';
import '../widgets/timetable/board.dart';
import '../widgets/timetable/daily.dart';
import '../widgets/timetable/weekly.dart';

class TimetableBoardPage extends StatefulWidget {
  final SitTimetableEntity timetable;

  const TimetableBoardPage({super.key, required this.timetable});

  @override
  State<TimetableBoardPage> createState() => _TimetableBoardPageState();
}

class _TimetableBoardPageState extends State<TimetableBoardPage> {
  final scrollController = ScrollController();
  final $displayMode = ValueNotifier(TimetableInit.storage.lastDisplayMode ?? DisplayMode.weekly);
  late final ValueNotifier<TimetablePos> $currentPos;

  SitTimetableEntity get timetable => widget.timetable;

  @override
  void initState() {
    super.initState();
    $displayMode.addListener(() {
      TimetableInit.storage.lastDisplayMode = $displayMode.value;
    });
    $currentPos = ValueNotifier(timetable.type.locate(DateTime.now()));
  }

  @override
  void dispose() {
    scrollController.dispose();
    $displayMode.dispose();
    $currentPos.dispose();
    super.dispose();
  }

  Widget buildDefault(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: $currentPos >> (ctx, pos) => i18n.weekOrderedName(number: pos.weekIndex + 1).text(),
        actions: [
          buildSwitchViewButton(),
          buildMyTimetablesButton(),
          buildMoreActionsButton(),
        ],
      ),
      floatingActionButton: InkWell(
        onLongPress: () async {
          if ($displayMode.value == DisplayMode.weekly) {
            await selectWeeklyTimetablePageToJump();
          } else {
            await selectDailyTimetablePageToJump();
          }
        },
        child: AutoHideFAB(
          controller: scrollController,
          child: const Icon(Icons.undo_rounded),
          onPressed: () async {
            final today = timetable.type.locate(DateTime.now());
            if ($currentPos.value != today) {
              eventBus.fire(JumpToPosEvent(today));
            }
          },
        ),
      ),
      body: TimetableBoard(
        timetable: timetable,
        $displayMode: $displayMode,
        $currentPos: $currentPos,
      ),
    );
  }

  Widget buildDesktop(BuildContext context) {
    final todayPos = timetable.type.locate(DateTime.now());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: $currentPos >> (ctx, pos) => i18n.weekOrderedName(number: pos.weekIndex + 1).text(),
        actions: [
          buildMyTimetablesButton(),
          buildMoreActionsButton(),
        ],
      ),
      floatingActionButton: InkWell(
        onLongPress: () async {
          if ($displayMode.value == DisplayMode.weekly) {
            await selectWeeklyTimetablePageToJump();
          } else {
            await selectDailyTimetablePageToJump();
          }
        },
        child: AutoHideFAB(
          controller: scrollController,
          child: const Icon(Icons.undo_rounded),
          onPressed: () async {
            final today = timetable.type.locate(DateTime.now());
            if ($currentPos.value != today) {
              eventBus.fire(JumpToPosEvent(today));
            }
          },
        ),
      ),
      body: [
        WeeklyTimetable(
          $currentPos: $currentPos,
          timetable: timetable,
        ).expanded(),
        // $currentPos >>
        //         (ctx, value) => TimetableOneDayPage(
        //       timetable: timetable,
        //       todayPos: todayPos,
        //       weekIndex: value.weekIndex,
        //       weekday: value.weekday,
        //     ).expanded(),
        DailyTimetable(
          $currentPos: $currentPos,
          timetable: timetable,
        ).expanded(),
      ].row(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      defaultBuilder: (ctx, screen) {
        return buildDefault(ctx);
      },
      layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
        desktop: (ctx, screen) {
          return buildDesktop(ctx);
        },
      ),
    );
  }

  Widget buildSwitchViewButton() {
    return $displayMode >>
        (ctx, mode) => SegmentedButton<DisplayMode>(
              showSelectedIcon: false,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 4)),
                visualDensity: VisualDensity.compact,
              ),
              segments: DisplayMode.values
                  .map((e) => ButtonSegment<DisplayMode>(
                        value: e,
                        label: e.l10n().text(),
                      ))
                  .toList(),
              selected: <DisplayMode>{mode},
              onSelectionChanged: (newSelection) {
                $displayMode.value = mode.toggle();
              },
            );
  }

  Widget buildMyTimetablesButton() {
    return IconButton(
      icon: multi.isCupertino
          ? Icon(Icons.person_outline, color: context.colorScheme.primary)
          : const Icon(Icons.person_rounded),
      onPressed: () async {
        final focusMode = Settings.focusTimetable;
        if (focusMode) {
          await context.push("/me");
        } else {
          await context.push("/timetable/mine");
        }
      },
    );
  }

  Widget buildMoreActionsButton() {
    final focusMode = Settings.focusTimetable;
    return PullDownMenuButton(
      itemBuilder: (ctx) => [
        PullDownItem(
          icon: Icons.screenshot,
          title: i18n.screenshot.screenshot,
          onTap: () async {
            await takeTimetableScreenshot(
              context: context,
              timetable: timetable,
              weekIndex: $currentPos.value.weekIndex,
            );
          },
        ),
        if (focusMode)
          PullDownItem(
            icon: Icons.calendar_month_outlined,
            title: i18n.mine.title,
            onTap: () async {
              await context.push("/timetable/mine");
            },
          ),
        PullDownItem(
          icon: Icons.palette_outlined,
          title: i18n.p13n.palette.title,
          onTap: () async {
            await context.push("/timetable/p13n");
          },
        ),
        PullDownItem(
          icon: Icons.view_comfortable_outlined,
          title: i18n.p13n.cell.title,
          onTap: () async {
            await context.push("/timetable/cell-style");
          },
        ),
        PullDownItem(
          icon: Icons.image_outlined,
          title: i18n.p13n.background.title,
          onTap: () async {
            await context.push("/timetable/background");
          },
        ),
        if (focusMode) ...buildFocusPopupActions(context),
        const PullDownDivider(),
        PullDownSelectable(
          title: i18n.focusTimetable,
          selected: focusMode,
          onTap: () async {
            Settings.focusTimetable = !focusMode;
          },
        ),
      ],
    );
  }

  Future<void> selectWeeklyTimetablePageToJump() async {
    final initialIndex = $currentPos.value.weekIndex;
    final controller = FixedExtentScrollController(initialItem: initialIndex);
    final todayPos = timetable.type.locate(DateTime.now());
    final todayIndex = todayPos.weekIndex;
    final week2Go = await context.showPicker(
          count: 20,
          controller: controller,
          ok: i18n.jump,
          okEnabled: (curSelected) => curSelected != initialIndex,
          actions: [
            (ctx, curSelected) => PlatformTextButton(
                  onPressed: (curSelected == todayIndex)
                      ? null
                      : () {
                          controller.animateToItem(todayIndex,
                              duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
                        },
                  child: i18n.findToday.text(),
                )
          ],
          make: (ctx, i) {
            return Text(i18n.weekOrderedName(number: i + 1));
          },
        ) ??
        initialIndex;
    controller.dispose();
    if (week2Go != initialIndex) {
      eventBus.fire(JumpToPosEvent($currentPos.value.copyWith(weekIndex: week2Go)));
    }
  }

  Future<void> selectDailyTimetablePageToJump() async {
    final currentPos = $currentPos.value;
    final initialWeekIndex = currentPos.weekIndex;
    final initialDayIndex = currentPos.weekday.index;
    final $week = FixedExtentScrollController(initialItem: initialWeekIndex);
    final $day = FixedExtentScrollController(initialItem: initialDayIndex);
    final todayPos = timetable.type.locate(DateTime.now());
    final todayWeekIndex = todayPos.weekIndex;
    final todayDayIndex = todayPos.weekday.index;
    final (week2Go, day2Go) = await context.showDualPicker(
          countA: 20,
          countB: 7,
          controllerA: $week,
          controllerB: $day,
          ok: i18n.jump,
          okEnabled: (weekSelected, daySelected) => weekSelected != initialWeekIndex || daySelected != initialDayIndex,
          actions: [
            (ctx, week, day) => PlatformTextButton(
                  onPressed: (week == todayWeekIndex && day == todayDayIndex)
                      ? null
                      : () {
                          $week.animateToItem(todayWeekIndex,
                              duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);

                          $day.animateToItem(todayDayIndex,
                              duration: const Duration(milliseconds: 500), curve: Curves.fastEaseInToSlowEaseOut);
                        },
                  child: i18n.findToday.text(),
                )
          ],
          makeA: (ctx, i) => i18n.weekOrderedName(number: i + 1).text(),
          makeB: (ctx, i) => Weekday.fromIndex(i).l10n().text(),
        ) ??
        (initialWeekIndex, initialDayIndex);
    $week.dispose();
    $day.dispose();
    if (week2Go != initialWeekIndex || day2Go != initialDayIndex) {
      eventBus.fire(JumpToPosEvent(TimetablePos(weekIndex: week2Go, weekday: Weekday.fromIndex(day2Go))));
    }
  }
}
