import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/widgets/grouped.dart';
import 'package:mimir/l10n/extension.dart';
import 'package:rettulf/rettulf.dart';

import '../entity/local.dart';
import '../i18n.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> records;

  const TransactionList({
    super.key,
    required this.records,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late Map<int, List<Transaction>> month2records;

  @override
  void initState() {
    super.initState();
    updateGroupedRecords();
  }

  @override
  void didUpdateWidget(covariant TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.records.equals(oldWidget.records)) {
      updateGroupedRecords();
    }
  }

  void updateGroupedRecords() {
    month2records = widget.records.groupListsBy((r) => r.datetime.year * 12 + r.datetime.month);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final groupTitleStyle = textTheme.titleMedium;
    final groupSubtitleStyle = textTheme.titleLarge;
    return CustomScrollView(
      slivers: month2records.entries.map(
        (e) {
          return GroupedSection(
            header: "a".text(),
            items: e.value,
            itemBuilder: (ctx, i, record) {
              return TransactionTile(record);
            },
          );
        },
      ).toList(),
    );
  }
}

// return GroupedListView<Transaction, int>(
//   groupBy: (element) => element.datetime.year * 12 + element.datetime.month,
//   order: GroupedListOrder.DESC,
//   itemComparator: (item1, item2) => item1.datetime.compareTo(item2.datetime),
//   // 生成每一组的头部
//   groupHeaderBuilder: (Transaction firstGroupRecord) {
//     double totalSpent = 0;
//     double totalIncome = 0;
//     int month = firstGroupRecord.datetime.month;
//     int year = firstGroupRecord.datetime.year;
//
//     for (final element in records) {
//       if (element.datetime.month == month && element.datetime.year == year) {
//         if (element.isConsume) {
//           totalSpent += element.deltaAmount;
//         } else {
//           totalIncome += element.deltaAmount;
//         }
//       }
//     }
//     return ListTile(
//       tileColor: context.bgColor,
//       title: context.formatYmText(firstGroupRecord.datetime).text(style: groupTitleStyle),
//       subtitle:
//           "${i18n.spentStatistics(totalSpent.toStringAsFixed(2))} ${i18n.incomeStatistics(totalIncome.toStringAsFixed(2))}"
//               .text(style: groupSubtitleStyle),
//     );
//   },
// );

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile(this.transaction, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.bestTitle ?? i18n.unknown, style: context.textTheme.titleSmall),
      subtitle: context.formatYmdhmsNum(transaction.datetime).text(),
      leading: transaction.type.icon.make(color: transaction.type.color, size: 32),
      trailing: transaction.toReadableString().text(
            style: TextStyle(color: transaction.billColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
    );
  }
}
