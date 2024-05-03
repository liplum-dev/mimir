import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/l10n/time.dart';
import 'package:sit/lifecycle.dart';
import 'package:sit/utils/byte_io/byte_io.dart';
import 'pos.dart';
import 'timetable_entity.dart';

part "loc.g.dart";

@JsonEnum()
enum TimetableDayLocMode {
  pos,
  date,
  ;

  String l10n() => "timetable.dayLocMode.$name".tr();
}

@JsonSerializable(ignoreUnannotated: true)
class TimetableDayLoc {
  @JsonKey()
  final TimetableDayLocMode mode;

  @JsonKey(name: "pos", includeIfNull: false)
  final TimetablePos? posInternal;

  /// starts with 0
  @JsonKey(name: "date", includeIfNull: false)
  final DateTime? dateInternal;

  const TimetableDayLoc({
    required this.mode,
    required this.posInternal,
    required this.dateInternal,
  });

  const TimetableDayLoc.pos(TimetablePos pos)
      : posInternal = pos,
        dateInternal = null,
        mode = TimetableDayLocMode.pos;

  TimetableDayLoc.byPos(int weekIndex, Weekday weekday)
      : posInternal = TimetablePos(weekIndex: weekIndex, weekday: weekday),
        dateInternal = null,
        mode = TimetableDayLocMode.pos;

  const TimetableDayLoc.date(DateTime date)
      : posInternal = null,
        dateInternal = date,
        mode = TimetableDayLocMode.date;

  TimetableDayLoc.byDate(int year, int month, int day)
      : posInternal = null,
        dateInternal = DateTime(year, month, day),
        mode = TimetableDayLocMode.date;

  TimetablePos get pos => posInternal!;

  DateTime get date => dateInternal!;

  void serialize(ByteWriter writer) {
    writer.uint8(mode.index);
    switch (mode) {
      case TimetableDayLocMode.pos:
        pos.serialize(writer);
      case TimetableDayLocMode.date:
        writer.datePacked(date, 2000);
    }
  }

  static TimetableDayLoc deserialize(ByteReader reader) {
    final mode = TimetableDayLocMode.values[reader.uint8()];
    switch (mode) {
      case TimetableDayLocMode.pos:
        return TimetableDayLoc.pos(TimetablePos.deserialize(reader));
      case TimetableDayLocMode.date:
        return TimetableDayLoc.date(reader.datePacked(2000));
    }
  }

  String toDartCode() {
    return switch (mode) {
      TimetableDayLocMode.pos => "TimetableDayLoc.pos(${pos.toDartCode()})",
      TimetableDayLocMode.date => 'TimetableDayLoc.date(DateTime(${date.year},${date.month},${date.day}))',
    };
  }

  String l10n() {
    return switch (mode) {
      TimetableDayLocMode.pos => pos.l10n(),
      TimetableDayLocMode.date => $key.currentContext!.formatYmdWeekText(date),
    };
  }

  Map<String, dynamic> toJson() => _$TimetableDayLocToJson(this);

  factory TimetableDayLoc.fromJson(Map<String, dynamic> json) => _$TimetableDayLocFromJson(json);

  SitTimetableDay? resolveDay(SitTimetableEntity entity) {
    return switch (mode) {
      TimetableDayLocMode.pos => entity.getDay(pos.weekIndex, pos.weekday),
      TimetableDayLocMode.date => entity.getDayOn(date),
    };
  }

  @override
  bool operator ==(Object other) {
    return other is TimetableDayLoc &&
        runtimeType == other.runtimeType &&
        mode == other.mode &&
        dateInternal == other.dateInternal &&
        posInternal == other.posInternal;
  }

  @override
  int get hashCode => Object.hash(mode, pos, dateInternal);

  @override
  String toString() {
    return switch (mode) {
      TimetableDayLocMode.pos => pos,
      TimetableDayLocMode.date => date,
    }
        .toString();
  }
}
