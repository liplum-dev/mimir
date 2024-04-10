import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/animation/animated.dart';
import 'package:statistics/statistics.dart';

import '../../entity/local.dart';
import "../../i18n.dart";
import '../../utils.dart';
import 'header.dart';

class ExpensePieChart extends StatefulWidget {
  final List<Transaction> records;

  const ExpensePieChart({
    super.key,
    required this.records,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    assert(widget.records.every((type) => type.isConsume));
    final (total: total, :parts) = separateTransactionByType(widget.records);
    final ascending = parts.entries.sortedBy<num>((e) => e.value.total).reversed.toList();
    return [
      ExpensePieChartHeader(
        total: total,
      ).padFromLTRB(16, 8, 0, 0),
      AspectRatio(
        aspectRatio: 1.5,
        child: buildChart(parts),
      ),
      buildLegends(parts).padAll(8).align(at: Alignment.topLeft),
      const Divider(),
      [
        ExpenseChartHeaderLabel("Summary").padFromLTRB(16, 8, 0, 0),
      ...ascending.map((e) {
        final amounts = e.value.records.map((e) => e.deltaAmount).toList();
        return ExpenseAverageTile(
          average: amounts.mean,
          max: amounts.max,
          type: e.key,
        );
      })].column(caa: CrossAxisAlignment.start).animatedSized(),
    ].column(caa: CrossAxisAlignment.start);
  }

  Widget buildChart(Map<TransactionType, ({double proportion, List<Transaction> records, double total})> parts) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        sectionsSpace: 0,
        centerSpaceRadius: 60,
        sections: parts.entries.mapIndexed((i, entry) {
          final isTouched = i == touchedIndex;
          final MapEntry(key: type, value: (records: _, :total, :proportion)) = entry;
          final color = type.color.harmonizeWith(context.colorScheme.primary);
          return PieChartSectionData(
            color: color.withOpacity(isTouched ? 1 : 0.8),
            value: total,
            title: "${(proportion * 100).toStringAsFixed(2)}%",
            titleStyle: context.textTheme.titleSmall,
            radius: isTouched ? 55 : 50,
            badgeWidget: Icon(type.icon, color: color),
            badgePositionPercentageOffset: 1.5,
          );
        }).toList(),
      ),
    );
  }

  Widget buildLegends(Map<TransactionType, ({double proportion, List<Transaction> records, double total})> parts) {
    return parts.entries
        .sortedBy<num>((e) => -e.value.total)
        .map((record) {
          final MapEntry(key: type, value: (records: _, :total, proportion: _)) = record;
          final color = type.color.harmonizeWith(context.colorScheme.primary);
          return Chip(
            avatar: Icon(type.icon, color: color),
            labelStyle: TextStyle(color: color),
            label: "${type.l10n()}: ${i18n.unit.rmb(total.toStringAsFixed(2))}".text(),
          );
        })
        .toList()
        .wrap(spacing: 4, runSpacing: 4);
  }
}

class ExpensePieChartHeader extends StatelessWidget {
  final double total;

  const ExpensePieChartHeader({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return ExpenseChartHeader(
      upper: "Total",
      content: "¥${total.toStringAsFixed(2)}",
    );
  }
}

class ExpenseAverageTile extends StatelessWidget {
  final TransactionType type;
  final double average;
  final double max;

  const ExpenseAverageTile({
    super.key,
    required this.type,
    required this.average,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(type.icon, color: type.color),
      title: "Average spent ¥${average.toStringAsFixed(2)} in ${type.l10n()}".text(),
      subtitle: "with a max spend of ¥${max.toStringAsFixed(2)}".text(),
    );
  }
}