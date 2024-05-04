import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/life/expense_records/utils.dart';
import 'package:sit/lifecycle.dart';
import 'package:sit/utils/date.dart';
import 'package:sit/utils/format.dart';
import 'package:statistics/statistics.dart';

import '../../entity/local.dart';
import '../../entity/statistics.dart';

class StatisticsDelegate {
  final StatisticsMode mode;
  final List<List<Transaction>> data;
  final Map<TransactionType, ({double proportion, List<Transaction> records, double total})> type2Stats;
  final StartTime2Records start2Records;
  final double average;
  final double total;
  final DateTime start;
  final Widget Function(BuildContext context, double value, TitleMeta meta) side;
  final Widget Function(BuildContext context, double value, TitleMeta meta) bottom;

  const StatisticsDelegate({
    required this.mode,
    required this.data,
    required this.type2Stats,
    required this.start2Records,
    required this.start,
    required this.average,
    required this.total,
    required this.side,
    required this.bottom,
  });

  factory StatisticsDelegate.byMode(
    StatisticsMode mode, {
    required DateTime start,
    required List<Transaction> records,
  }) {
    switch (mode) {
      case StatisticsMode.day:
        return StatisticsDelegate.day(start: start, records: records);
      case StatisticsMode.week:
        return StatisticsDelegate.week(start: start, records: records);
      case StatisticsMode.month:
        return StatisticsDelegate.month(start: start, records: records);
      case StatisticsMode.year:
        return StatisticsDelegate.year(start: start, records: records);
    }
  }

  factory StatisticsDelegate.day({
    required DateTime start,
    required List<Transaction> records,
  }) {
    final now = DateTime.now();
    final data = List.generate(
      now.inTheSameDay(start) ? now.hour + 1 : 24,
      (i) => <Transaction>[],
    );
    for (final record in records) {
      // add data at the same weekday.
      // sunday goes first
      data[record.timestamp.hour].add(record);
    }
    final (:total, :type2Stats) = statisticsTransactionByType(records);
    final dayTotals = data.map((monthRecords) => monthRecords.map((r) => r.deltaAmount).sum).toList();
    return StatisticsDelegate(
      mode: StatisticsMode.day,
      start: start,
      start2Records: StatisticsMode.day.resort(records),
      data: data,
      side: _buildSideTitle,
      average: dayTotals.isEmpty ? 0.0 : dayTotals.mean,
      type2Stats: type2Stats,
      total: total,
      bottom: (ctx, value, mate) {
        final index = value.toInt();
        if (!(index == 0 || index == data.length - 1) && index % 4 != 0) {
          return const SizedBox();
        }
        return SideTitleWidget(
          axisSide: mate.axisSide,
          child: Text(
            style: ctx.textTheme.labelMedium,
            "${index}",
          ),
        );
      },
    );
  }

  factory StatisticsDelegate.week({
    required DateTime start,
    required List<Transaction> records,
  }) {
    final now = DateTime.now();
    final data = List.generate(
      start.year == now.year && start.week == now.week ? now.calendarOrderWeekday + 1 : 7,
      (i) => <Transaction>[],
    );
    for (final record in records) {
      // add data at the same weekday.
      // sunday goes first
      data[record.timestamp.calendarOrderWeekday].add(record);
    }
    final (:total, :type2Stats) = statisticsTransactionByType(records);
    final dayTotals =
        data.map((monthRecords) => monthRecords.map((r) => r.deltaAmount).sum).where((total) => total > 0).toList();
    return StatisticsDelegate(
      mode: StatisticsMode.week,
      start: start,
      start2Records: StatisticsMode.week.resort(records),
      data: data,
      side: _buildSideTitle,
      average: dayTotals.isEmpty ? 0.0 : dayTotals.mean,
      type2Stats: type2Stats,
      total: total,
      bottom: (ctx, value, mate) {
        final index = value.toInt();
        return SideTitleWidget(
          axisSide: mate.axisSide,
          child: Text(
            style: ctx.textTheme.labelMedium,
            Weekday.calendarOrder[index].l10nShort(),
          ),
        );
      },
    );
  }

  factory StatisticsDelegate.month({
    required DateTime start,
    required List<Transaction> records,
  }) {
    final now = DateTime.now();
    final data = List.generate(
      start.year == now.year && start.month == now.month ? now.day : daysInMonth(year: start.year, month: start.month),
      (i) => <Transaction>[],
    );
    for (final record in records) {
      // add data on the same day.
      data[record.timestamp.day - 1].add(record);
    }
    final (:total, :type2Stats) = statisticsTransactionByType(records);
    final dayTotals =
        data.map((monthRecords) => monthRecords.map((r) => r.deltaAmount).sum).where((total) => total > 0).toList();
    final sep = data.length ~/ 5;
    return StatisticsDelegate(
      mode: StatisticsMode.month,
      start: start,
      start2Records: StatisticsMode.month.resort(records),
      data: data,
      average: dayTotals.isEmpty ? 0.0 : dayTotals.mean,
      type2Stats: type2Stats,
      total: total,
      side: _buildSideTitle,
      bottom: (ctx, value, meta) {
        final index = value.toInt();
        if (sep != 0 && (!(index == 0 || index == data.length - 1) && index % sep != 0)) {
          return const SizedBox();
        }
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(
            style: ctx.textTheme.labelMedium,
            "${index + 1}",
          ),
        );
      },
    );
  }

  factory StatisticsDelegate.year({
    required DateTime start,
    required List<Transaction> records,
  }) {
    final _monthFormat = DateFormat.MMM($key.currentContext!.locale.toString());
    final now = DateTime.now();
    final data = List.generate(start.year == now.year ? now.month : 12, (i) => <Transaction>[]);
    for (final record in records) {
      // add data in the same month.
      data[record.timestamp.month - 1].add(record);
    }
    final (:total, :type2Stats) = statisticsTransactionByType(records);
    final monthTotals =
        data.map((monthRecords) => monthRecords.map((r) => r.deltaAmount).sum).where((total) => total > 0).toList();
    return StatisticsDelegate(
      mode: StatisticsMode.year,
      start: start,
      start2Records: StatisticsMode.year.resort(records),
      data: data,
      average: monthTotals.isEmpty ? 0.0 : monthTotals.mean,
      type2Stats: type2Stats,
      total: total,
      side: _buildSideTitle,
      bottom: (ctx, value, mate) {
        final index = value.toInt();
        final text = _monthFormat.format(DateTime(0, index + 1));
        return SideTitleWidget(
          axisSide: mate.axisSide,
          child: Text(
            style: ctx.textTheme.labelMedium,
            text.substring(0, min(3, text.length)),
          ),
        );
      },
    );
  }

  static Widget _buildSideTitle(BuildContext ctx, double value, TitleMeta meta) {
    String text = '¥${formatWithoutTrailingZeros(value)}';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        style: ctx.textTheme.labelMedium,
        text,
      ),
    );
  }
}
