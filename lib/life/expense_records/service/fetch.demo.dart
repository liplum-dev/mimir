import 'dart:math';

import 'package:screenshot/screenshot.dart';
import 'package:sit/credentials/init.dart';
import 'package:sit/r.dart';
import 'package:sit/utils/random.dart';

import '../entity/local.dart';
import 'fetch.dart';

class DemoExpenseService implements ExpenseService {
  const DemoExpenseService();

  @override
  Future<List<Transaction>> fetch({
    required String studentID,
    required DateTime from,
    required DateTime to,
  }) async {
    final rand = Random((CredentialsInit.storage.oaCredentials?.account ?? R.demoModeOaCredentials.account).hashCode);
    return _generate(300, rand);
  }
}

final _type2info = {
  TransactionType.food: ([
    (
      name: "小应食堂",
      notes: [
        "一号窗口",
        "一号窗口",
      ],
    ),
    (
      name: "KFC",
      notes: [
        "疯狂星期四",
        "v我50",
      ],
    ),
  ]),
  TransactionType.water: ([
    (
      name: "小应饮水机",
      notes: [
        "热水",
        "冰水",
      ],
    ),
  ]),
  TransactionType.coffee: ([
    (
      name: "小应咖啡吧",
      notes: [
        "美式(冰)",
        "生椰拿铁",
        "意式浓缩",
      ],
    ),
  ]),
  TransactionType.store: ([
    (
      name: "小应商店",
      notes: [
        "百事可乐",
        "东方树叶",
        "RIO",
      ],
    ),
  ]),
  TransactionType.library: ([
    (
      name: "小应图书&咖啡",
      notes: [
        "逾期罚款",
        "咖啡",
      ],
    ),
  ]),
  TransactionType.shower: ([
    (
      name: "小应澡堂",
      notes: [
        "男",
        "女",
      ],
    ),
    (
      name: "小应按摩沙龙·免费果盘",
      notes: [
        "328套餐",
        "198套餐",
      ],
    ),
  ]),
  TransactionType.other: [
    (
      name: "小应加油站",
      notes: [
        "#92",
        "#95",
      ],
    ),
    (
      name: "小应充电桩",
      notes: [
        "直流快充",
        "交流慢充",
      ],
    ),
  ],
};

final _type2weight = (
  types: [
    TransactionType.food,
    TransactionType.shower,
    TransactionType.water,
    TransactionType.store,
    TransactionType.coffee,
    TransactionType.library,
    TransactionType.other,
  ],
  weights: [
    0.6,
    0.12,
    0.06,
    0.12,
    0.04,
    0.01,
    0.05,
  ]
);

const _topUp = [
  "支付宝充值",
  "微信充值",
  "数字人民币充值",
  "银行卡充值",
];

List<Transaction> _generate(int count, Random rand) {
  final res = <Transaction>[];
  double balance = 100;
  DateTime time = DateTime.now();
  for (var i = 0; i < count; i++) {
    final type = randomChoice(_type2weight.types,_type2weight.weights);
    final entries = _type2info[type];
    if (entries == null) continue;
    final entry = entries[rand.nextInt(entries.length)];
    final cost = min(balance, (rand.nextDouble() * 100).ceilToDouble());
    res.add(_make(
      type: type,
      deviceName: entry.name,
      note: entry.notes[rand.nextInt(entry.notes.length)],
      time: time,
      balance: balance,
      delta: -cost,
    ));
    balance -= cost;
    balance = balance.toPrecision(2);
    // if balance is insufficient
    if (balance <= 0) {
      final topUp = (rand.nextInt(150) + 50).toDouble();
      final topUpName = _topUp[rand.nextInt(_topUp.length)];
      time = time.copyWith(
        minute: time.minute - rand.nextInt(60),
        second: time.second - rand.nextInt(60),
      );
      res.add(_make(
        type: TransactionType.subsidy,
        deviceName: "领取终端",
        note: topUpName,
        time: time,
        balance: balance,
        delta: topUp,
      ));

      time = time.copyWith(
        minute: time.minute - rand.nextInt(5),
        second: time.second - rand.nextInt(60),
      );
      res.add(_make(
        type: TransactionType.topUp,
        deviceName: topUpName,
        note: "",
        time: time,
        balance: balance,
        delta: 0,
      ));
      balance += topUp;
    }
    time = time.copyWith(
      day: time.day - rand.nextInt(2),
      hour: time.hour - rand.nextInt(24),
      minute: time.minute - rand.nextInt(60),
      second: time.second - rand.nextInt(60),
    );
  }
  return res;
}

Transaction _make({
  required TransactionType type,
  required String deviceName,
  required String note,
  required DateTime time,
  required double balance,
  required double delta,
}) {
  return Transaction(
    timestamp: time,
    consumerId: 99999,
    type: type,
    balanceBefore: balance,
    balanceAfter: balance + delta,
    deltaAmount: delta.abs(),
    deviceName: deviceName,
    note: note,
  );
}
