import 'package:collection/collection.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/widgets/card.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/local.dart';
import '../utils.dart';
import "../i18n.dart";

class ExpensePieChart extends StatefulWidget {
  final Map<TransactionType, ({List<Transaction> records, double percentage})> records;

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
    assert(widget.records.keys.every((type) => type.isConsume));
    return OutlinedCard(
      child: [
        AspectRatio(
          aspectRatio: 1,
          child: buildChart(),
        ),
        buildLegends(),
      ].column(),
    );
  }

  Widget buildChart() {
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
        sections: widget.records.entries.mapIndexed((i, entry) {
          final isTouched = i == touchedIndex;
          final MapEntry(key: type, value: (:records, :percentage)) = entry;
          final (income: _, :outcome) = accumulateTransactionIncomeOutcome(records);
          final color = type.color.harmonizeWith(context.colorScheme.primary);
          return PieChartSectionData(
            color: color.withOpacity(isTouched ? 1 : 0.8),
            value: outcome,
            title: i18n.unit.rmb(outcome.toStringAsFixed(2)),
            radius: isTouched ? 55 : 50,
            badgeWidget: Icon(type.icon, color: color),
            badgePositionPercentageOffset: 1.5,
            titleStyle: context.textTheme.titleSmall,
          );
        }).toList(),
      ),
    );
  }

  Widget buildLegends() {
    final all = widget.records.entries.toList();
    return all
        .map((record) {
          final MapEntry(key: type, value: (:records, :percentage)) = record;
          final color = type.color.harmonizeWith(context.colorScheme.primary);
          return ListTile(
            dense: true,
            leading: Icon(type.icon, color: color),
            titleTextStyle: TextStyle(color: color),
            title: type.localized().text(),
            subtitleTextStyle: TextStyle(color: color),
            subtitle: "${(percentage * 100).toStringAsFixed(2)}%".text(),
          );
        })
        .toList()
        .column();
  }
}
