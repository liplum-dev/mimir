import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sit/design/adaptive/menu.dart';
import 'package:sit/design/widgets/fab.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/timetable/page/screenshot.dart';
import '../entity/display.dart';
import '../entity/timetable.dart';
import '../events.dart';
import '../i18n.dart';
import '../entity/timetable_entity.dart';
import '../init.dart';
import '../entity/pos.dart';
import '../utils.dart';
import '../widgets/focus.dart';
import '../widgets/timetable/board.dart';
import 'mine.dart';

class TimetableBoardPage extends StatefulWidget {
  final int id;
  final SitTimetableEntity timetable;

  const TimetableBoardPage({
    super.key,
    required this.id,
    required this.timetable,
  });

  @override
  State<TimetableBoardPage> createState() => _TimetableBoardPageState();
}

class _TimetableBoardPageState extends State<TimetableBoardPage> {
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
    $displayMode.dispose();
    $currentPos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: $currentPos >> (ctx, pos) => i18n.weekOrderedName(number: pos.weekIndex + 1).text(),
        actions: [
          buildSwitchViewButton(),
          buildMoreActionsButton(),
        ],
      ),
      floatingActionButton: TimetableJumpButton(
        $displayMode: $displayMode,
        $currentPos: $currentPos,
        timetable: timetable.type,
      ),
      body: TimetableBoard(
        timetable: timetable,
        $displayMode: $displayMode,
        $currentPos: $currentPos,
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

  Widget buildMoreActionsButton() {
    final focusMode = Settings.focusTimetable;
    return PullDownMenuButton(
      itemBuilder: (ctx) => [
        PullDownItem(
          icon: Icons.calendar_month,
          title: i18n.mine.title,
          onTap: () async {
            await context.push("/timetable/mine");
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
        const PullDownDivider(),
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
        PullDownItem(
          icon: Icons.dashboard_customize,
          title: i18n.patch.title,
          onTap: () async {
            await editTimetablePatch(
              context: ctx,
              id: widget.id,
              timetable: widget.timetable.type,
            );
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
}

Future<void> _selectWeeklyTimetablePageToJump({
  required BuildContext context,
  required SitTimetable timetable,
  required ValueNotifier<TimetablePos> $currentPos,
}) async {
  final initialIndex = $currentPos.value.weekIndex;
  final week2Go = await selectWeekInTimetable(
    context: context,
    timetable: timetable,
    initialWeekIndex: initialIndex,
    submitLabel: i18n.jump,
  );
  if (week2Go == null) return;
  if (week2Go != initialIndex) {
    eventBus.fire(JumpToPosEvent($currentPos.value.copyWith(weekIndex: week2Go)));
  }
}

Future<void> _selectDailyTimetablePageToJump({
  required BuildContext context,
  required SitTimetable timetable,
  required ValueNotifier<TimetablePos> $currentPos,
}) async {
  final currentPos = $currentPos.value;
  final pos2Go = await selectDayInTimetable(
    context: context,
    timetable: timetable,
    initialPos: currentPos,
    submitLabel: i18n.jump,
  );
  if (pos2Go == null) return;
  if (pos2Go != currentPos) {
    eventBus.fire(JumpToPosEvent(pos2Go));
  }
}

Future<void> _jumpToToday({
  required SitTimetable timetable,
  required ValueNotifier<TimetablePos> $currentPos,
}) async {
  final today = timetable.locate(DateTime.now());
  if ($currentPos.value != today) {
    eventBus.fire(JumpToPosEvent(today));
  }
}

class TimetableJumpButton extends StatelessWidget {
  final ValueNotifier<DisplayMode> $displayMode;
  final ValueNotifier<TimetablePos> $currentPos;
  final SitTimetable timetable;
  final ScrollController? controller;

  const TimetableJumpButton({
    super.key,
    required this.$displayMode,
    required this.timetable,
    required this.$currentPos,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        if ($displayMode.value == DisplayMode.weekly) {
          await _selectWeeklyTimetablePageToJump(
            context: context,
            timetable: timetable,
            $currentPos: $currentPos,
          );
        } else {
          await _selectDailyTimetablePageToJump(
            context: context,
            timetable: timetable,
            $currentPos: $currentPos,
          );
        }
      },
      child: buildFab(),
    );
  }

  Widget buildFab() {
    final controller = this.controller;
    if (controller != null) {
      return AutoHideFAB(
        controller: controller,
        child: const Icon(Icons.undo_rounded),
        onPressed: () async {
          await _jumpToToday(timetable: timetable, $currentPos: $currentPos);
        },
      );
    } else {
      return FloatingActionButton(
        child: const Icon(Icons.undo_rounded),
        onPressed: () async {
          await _jumpToToday(timetable: timetable, $currentPos: $currentPos);
        },
      );
    }
  }
}
