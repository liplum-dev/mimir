import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sit/life/expense_records/entity/local.dart';
import 'package:sit/lifecycle.dart';

import 'package:sit/school/utils.dart';
import 'package:sit/utils/date.dart';

import 'entity/remote.dart';
import 'entity/statistics.dart';
import 'i18n.dart';

const deviceName2Type = {
  '开水': TransactionType.water,
  '浴室': TransactionType.shower,
  '咖啡吧': TransactionType.coffee,
  '食堂': TransactionType.food,
  '超市': TransactionType.store,
  '图书馆': TransactionType.library,
};

TransactionType parseType(Transaction trans) {
  if (trans.note.contains("补助")) {
    return TransactionType.subsidy;
  } else if (trans.note.contains("充值") || trans.note.contains("余额转移") || !trans.isConsume) {
    return TransactionType.topUp;
  } else if (trans.note.contains("消费") || trans.isConsume) {
    for (MapEntry<String, TransactionType> entry in deviceName2Type.entries) {
      String name = entry.key;
      TransactionType type = entry.value;
      if (trans.deviceName.contains(name)) {
        return type;
      }
    }
  }
  return TransactionType.other;
}

Transaction parseFull(TransactionRaw raw) {
  final transaction = Transaction(
    timestamp: parseDatetime(raw),
    balanceBefore: raw.balanceBeforeTransaction,
    balanceAfter: raw.balanceAfterTransaction,
    deltaAmount: raw.amount.abs(),
    deviceName: mapChinesePunctuations(raw.deviceName ?? ""),
    note: raw.name,
    consumerId: raw.customerId,
    type: TransactionType.other,
  );
  return transaction.copyWith(
    type: parseType(transaction),
  );
}

DateTime parseDatetime(TransactionRaw raw) {
  final date = raw.date;
  final year = int.parse(date.substring(0, 4));
  final month = int.parse(date.substring(4, 6));
  final day = int.parse(date.substring(6, 8));

  final time = raw.time;
  final hour = int.parse(time.substring(0, 2));
  final min = int.parse(time.substring(2, 4));
  final sec = int.parse(time.substring(4, 6));
  return DateTime(year, month, day, hour, min, sec);
}

typedef YearMonth = ({int year, int month});

extension YearMonthX on YearMonth {
  int compareTo(YearMonth other, {bool ascending = true}) {
    final sign = ascending ? 1 : -1;
    return switch (this.year - other.year) {
      > 0 => 1 * sign,
      < 0 => -1 * sign,
      _ => switch (this.month - other.month) {
          > 0 => 1 * sign,
          < 0 => -1 * sign,
          _ => 0,
        }
    };
  }

  DateTime toDateTime() => DateTime(year, month);
}

List<({YearMonth time, List<Transaction> records})> groupTransactionsByMonthYear(
  List<Transaction> records,
) {
  final groupByYearMonth = records
      .groupListsBy((r) => (year: r.timestamp.year, month: r.timestamp.month))
      .entries
      // the latest goes first
      .map((e) => (time: e.key, records: e.value.sorted((a, b) => -a.timestamp.compareTo(b.timestamp))))
      .toList();
  groupByYearMonth.sort((a, b) => a.time.compareTo(b.time, ascending: false));
  return groupByYearMonth;
}

bool validateTransaction(Transaction t) {
  if (t.type == TransactionType.topUp) {
    return false;
  }
  return true;
}

/// Accumulates the income and outcome.
/// Ignores invalid transactions by [validateTransaction].
({double income, double outcome}) accumulateTransactionIncomeOutcome(List<Transaction> transactions) {
  double income = 0;
  double outcome = 0;
  for (final t in transactions) {
    if (!validateTransaction(t)) continue;
    if (t.isConsume) {
      outcome += t.deltaAmount;
    } else {
      income += t.deltaAmount;
    }
  }
  return (income: income, outcome: outcome);
}

/// Accumulates the [Transaction.deltaAmount].
double accumulateTransactionAmount(List<Transaction> transactions) {
  var total = 0.0;
  for (final t in transactions) {
    total += t.deltaAmount;
  }
  return total;
}

({double total, Map<TransactionType, ({double proportion, List<Transaction> records, double total})> type2Stats})
    statisticsTransactionByType(
  List<Transaction> records,
) {
  final type2transactions = records.groupListsBy((record) => record.type);
  final type2total = type2transactions.map((type, records) => MapEntry(type, accumulateTransactionAmount(records)));
  final total = type2total.values.sum;
  return (
    total: total,
    type2Stats: type2transactions.map((type, records) {
      final (income: _, :outcome) = accumulateTransactionIncomeOutcome(records);
      return MapEntry(type, (records: records, total: outcome, proportion: (type2total[type] ?? 0) / total));
    })
  );
}

String resolveTime4Display({
  required BuildContext context,
  required StatisticsMode mode,
  required DateTime date,
}) {
  final now = DateTime.now();
  final local = $key.currentContext?.locale.toString();
  switch (mode) {
    case StatisticsMode.day:
      final dayDiff = now.difference(date).inDays;
      if (dayDiff == 0) {
        return i18n.stats.today;
      } else if (dayDiff == 1) {
        return i18n.stats.yesterday;
      }
      return formatDateSpan(from: date, to: StatisticsMode.day.getAfterUnitTime(start: date));
    case StatisticsMode.week:
      if (date.year == now.year) {
        final nowWeek = now.week;
        final dateWeek = date.week;
        if (dateWeek == nowWeek) {
          return i18n.stats.thisWeek;
        } else if (dateWeek == nowWeek - 1) {
          return i18n.stats.lastWeek;
        }
      }
      return formatDateSpan(from: date, to: StatisticsMode.week.getAfterUnitTime(start: date));
    case StatisticsMode.month:
      final yearMonthFormat = DateFormat.yMMMM(local);
      final monthFormat = DateFormat.MMMM(local);
      if (date.year == now.year) {
        if (date.month == now.month) {
          return i18n.stats.thisMonth;
        } else if (date.month == now.month - 1) {
          return i18n.stats.lastMonth;
        } else {
          return monthFormat.format(date);
        }
      } else {
        return yearMonthFormat.format(date);
      }
    case StatisticsMode.year:
      final yearFormat = DateFormat.y(local);
      if (date.year == now.year) {
        return i18n.stats.thisYear;
      } else if (date.year == now.year - 1) {
        return i18n.stats.lastYear;
      } else {
        return yearFormat.format(date);
      }
  }
}
