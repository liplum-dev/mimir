import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/utils/byte_io/byte_io.dart';

import 'timetable.dart';
import '../i18n.dart';

part "pos.g.dart";

@JsonSerializable()
@CopyWith(skipFields: true)
class TimetablePos {
  /// starts with 0
  final int weekIndex;

  /// starts with 0
  final Weekday weekday;

  const TimetablePos({
    required this.weekIndex,
    required this.weekday,
  });

  const TimetablePos.fromDayIndex(int dayIndex)
      : this(
          weekIndex: dayIndex ~/ 7,
          weekday: dayIndex % 7 == 0
              ? Weekday.monday
              : dayIndex % 7 == 1
                  ? Weekday.tuesday
                  : dayIndex % 7 == 2
                      ? Weekday.wednesday
                      : dayIndex % 7 == 3
                          ? Weekday.thursday
                          : dayIndex % 7 == 4
                              ? Weekday.friday
                              : dayIndex % 7 == 5
                                  ? Weekday.saturday
                                  : dayIndex % 7 == 6
                                      ? Weekday.sunday
                                      : Weekday.monday,
        );

  static const initial = TimetablePos(weekIndex: 0, weekday: Weekday.monday);

  static TimetablePos locate(
    DateTime current, {
    required DateTime relativeTo,
    TimetablePos? fallback,
  }) {
    // calculate how many days have passed.
    int totalDays = current.clearTime().difference(relativeTo.clearTime()).inDays;

    int week = totalDays ~/ 7 + 1;
    int day = totalDays % 7 + 1;
    if (totalDays >= 0 && 1 <= week && week <= 20 && 1 <= day && day <= 7) {
      return TimetablePos(weekIndex: week - 1, weekday: Weekday.fromIndex(day - 1));
    } else {
      // if out of range, fallback will be return.
      return fallback ?? initial;
    }
  }

  void serialize(ByteWriter writer) {
    writer.uint8(weekIndex);
    writer.uint8(weekday.index);
  }

  static TimetablePos deserialize(ByteReader reader) {
    final weekIndex = reader.uint8();
    final weekdayIndex = reader.uint8();
    return TimetablePos(weekIndex: weekIndex, weekday: Weekday.fromIndex(weekdayIndex));
  }

  String l10n() {
    return "${i18n.weekOrderedName(number: weekIndex + 1)} ${weekday.l10n()}";
  }

  String toDartCode() {
    return "TimetablePos(weekIndex:$weekIndex,weekday:$weekday)";
  }

  factory TimetablePos.fromJson(Map<String, dynamic> json) => _$TimetablePosFromJson(json);

  Map<String, dynamic> toJson() => _$TimetablePosToJson(this);

  @override
  bool operator ==(Object other) {
    return other is TimetablePos &&
        runtimeType == other.runtimeType &&
        weekIndex == other.weekIndex &&
        weekday == other.weekday;
  }

  @override
  int get hashCode => Object.hash(weekIndex, weekday);

  @override
  String toString() {
    return (week: weekIndex, day: weekday).toString();
  }
}

extension _DateTimeX on DateTime {
  DateTime clearTime([int hour = 0, int minute = 0, int second = 0]) {
    return DateTime(year, month, day, hour, minute, second);
  }
}

extension TimetableX on SitTimetable {
  TimetablePos locate(DateTime current) {
    return TimetablePos.locate(current, relativeTo: startDate);
  }
}

// TODO: finish timetable lesson pos
class TimetableLessonPos {
  final String courseCode;

  /// starts with 0
  final int weekIndex;

  /// starts with 0
  final Weekday weekday;

  const TimetableLessonPos({
    required this.courseCode,
    required this.weekIndex,
    required this.weekday,
  });
}
