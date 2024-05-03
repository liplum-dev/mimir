import 'package:quiver/collection.dart';
import 'package:sit/timetable/utils.dart';

extension ListX<E> on List<E> {
  List<E> distinct({bool inplace = true}) {
    final ids = <E>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(x));
    return list;
  }

  List<E> distinctBy<Id>(Id Function(E element) id, {bool inplace = true}) {
    final ids = <Id>{};
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id(x)));
    return list;
  }

  /// Accesses elements using a negative index similar to Python.
  /// A negative index counts from the end of the list.
  ///
  /// Throws an [ArgumentError] if the index is out of bounds.
  E indexAt(int index) {
    if (index < 0) {
      final absIndex = index.abs();
      if (absIndex > length) {
        throw ArgumentError("List index out of range: $index");
      }
      return this[length + index];
    } else {
      return this[index];
    }
  }
}

extension IterableX<E> on Iterable<E> {
  E? maxByOrNull<T extends Comparable<T>>(T Function(E) valueOf) {
    final it = iterator;
    if (it.moveNext()) {
      final first = it.current;
      var tempMax = valueOf(first);
      var tempE = first;
      while (it.moveNext()) {
        final cur = it.current;
        final curValue = valueOf(cur);
        if (curValue.compareTo(tempMax) > 0) {
          tempMax = curValue;
          tempE = cur;
        }
      }
      return tempE;
    }
    return null;
  }

  E maxBy<T extends Comparable<T>>(T Function(E) valueOf) {
    return maxByOrNull(valueOf)!;
  }
}

ListMultimap<K, V> listMultimapFromEntries<T, K, V>(
  Iterable<T> list, {
  required K Function(T t) key,
  required V Function(T t) value,
}) {
  final map = ListMultimap<K, V>();
  for (final e in list) {
    map.add(key(e), value(e));
  }
  return map;
}
