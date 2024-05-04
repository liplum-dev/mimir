import 'dart:math';

import '../entity/balance.dart';
import 'electricity.dart';

class DemoElectricityService implements ElectricityService {
  const DemoElectricityService();

  @override
  Future<ElectricityBalance> getBalance(String room) async {
    final rand = Random(room.hashCode);
    final rand2 = Random();
    final base = rand.nextInt(10000) / 100;
    return ElectricityBalance.all(
      roomNumber: room,
      balance: base + rand2.nextInt(100) / 10 - 5,
    );
  }

  @override
  List<String> getRoomNumberCandidates() {
    return ["114514", "1919", "1314", "6666"];
  }
}
