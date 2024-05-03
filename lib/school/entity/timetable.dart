import 'package:flutter/widgets.dart';
import 'package:sit/entity/campus.dart';
import 'package:sit/l10n/common.dart';
import 'package:sit/l10n/extension.dart';

class TimePoint {
  final int hour;
  final int minute;

  const TimePoint(this.hour, this.minute);

  const TimePoint.fromMinutes(int minutes)
      : hour = minutes ~/ 60,
        minute = minutes % 60;

  @override
  String toString() => '$hour:${'$minute'.padLeft(2, '0')}';

  String toStringPrefixed0({bool hour = true, bool minute = true}) {
    final sb = StringBuffer();
    if (hour) {
      sb.write(this.hour.toString().padLeft(2, '0'));
    } else {
      sb.write(this.hour.toString());
    }
    sb.write(':');
    if (minute) {
      sb.write(this.minute.toString().padLeft(2, '0'));
    } else {
      sb.write(this.minute.toString());
    }
    return sb.toString();
  }

  String l10n(BuildContext context) => context.formatHmNum(DateTime(0, 1, 1, hour, minute));

  TimeDuration difference(TimePoint b) => TimeDuration.fromMinutes(totalMinutes - b.totalMinutes);

  TimePoint operator -(TimeDuration b) => TimePoint.fromMinutes(totalMinutes - b.totalMinutes);

  TimePoint operator +(TimeDuration b) => TimePoint.fromMinutes(totalMinutes + b.totalMinutes);

  int get totalMinutes => hour * 60 + minute;
}

extension DateTimeTimePointX on DateTime {
  DateTime addTimePoint(TimePoint t) {
    return add(Duration(hours: t.hour, minutes: t.minute));
  }
}

class TimeDuration {
  final int hour;
  final int minute;
  static const _i18n = TimeI18n();

  int get totalMinutes => hour * 60 + minute;

  const TimeDuration(this.hour, this.minute);

  const TimeDuration.fromMinutes(int minutes)
      : hour = minutes ~/ 60,
        minute = minutes % 60;

  String localized() {
    final h = "$hour";
    final min = "$minute".padLeft(2, '0');
    if (hour == 0) {
      return _i18n.minuteFormat(min);
    } else if (minute == 0) {
      return _i18n.hourFormat(h);
    }
    return _i18n.hourMinuteFormat(h, min);
  }

  Duration toDuration() => Duration(hours: hour, minutes: minute);
}

typedef ClassTime = ({TimePoint begin, TimePoint end});

extension ClassTimeX on ClassTime {
  TimeDuration get duration {
    return end.difference(begin);
  }
}

const fengxianTimetable = <ClassTime>[
  // morning
  (begin: TimePoint(8, 20), end: TimePoint(9, 05)),
  (begin: TimePoint(9, 10), end: TimePoint(9, 55)),
  (begin: TimePoint(10, 15), end: TimePoint(11, 00)),
  (begin: TimePoint(11, 05), end: TimePoint(11, 50)),
  // afternoon
  (begin: TimePoint(13, 00), end: TimePoint(13, 45)),
  (begin: TimePoint(13, 50), end: TimePoint(14, 35)),
  (begin: TimePoint(14, 55), end: TimePoint(15, 40)),
  (begin: TimePoint(15, 45), end: TimePoint(16, 30)),
  // night
  (begin: TimePoint(18, 00), end: TimePoint(18, 45)),
  (begin: TimePoint(18, 50), end: TimePoint(19, 35)),
  (begin: TimePoint(19, 40), end: TimePoint(20, 25)),
];

const xuhuiCampusTimetable = <ClassTime>[
  // morning
  (begin: TimePoint(8, 00), end: TimePoint(8, 45)),
  (begin: TimePoint(8, 50), end: TimePoint(9, 35)),
  (begin: TimePoint(9, 55), end: TimePoint(10, 40)),
  (begin: TimePoint(10, 45), end: TimePoint(11, 30)),
  // afternoon
  (begin: TimePoint(13, 00), end: TimePoint(13, 45)),
  (begin: TimePoint(13, 50), end: TimePoint(14, 35)),
  (begin: TimePoint(14, 55), end: TimePoint(15, 40)),
  (begin: TimePoint(15, 45), end: TimePoint(16, 30)),
  // night
  (begin: TimePoint(18, 00), end: TimePoint(18, 45)),
  (begin: TimePoint(18, 50), end: TimePoint(19, 35)),
  (begin: TimePoint(19, 40), end: TimePoint(20, 25)),
];

List<ClassTime> getTeachingBuildingTimetable(Campus campus, [String? place]) {
  if (campus == Campus.xuhui) {
    return xuhuiCampusTimetable;
  }
  if (campus == Campus.fengxian) {
    return fengxianTimetable;
  }
  return fengxianTimetable;
}
