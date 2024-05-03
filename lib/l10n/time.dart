import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  int toJson() => index;

  static const calendarOrder = [
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
  ];

  int getIndex({required Weekday firstDay}) {
    return (this - firstDay.index).index;
  }

  const Weekday();
  static Weekday fromJson(int json) => Weekday.values.elementAtOrNull(json) ?? Weekday.monday;

  static Weekday fromIndex(int index) {
    assert(0 <= index && index < Weekday.values.length);
    return Weekday.values[index % Weekday.values.length];
  }

  String l10n() => "weekday.$index".tr();

  String l10nShort() => "weekdayShort.$index".tr();

  static List<Weekday> genSequence(Weekday firstDay) {
    return List.generate(7, (index) => firstDay + index);
  }

  Weekday operator +(int delta) {
    return Weekday.values[(index + delta) % Weekday.values.length];
  }

  Weekday operator -(int delta) {
    return Weekday.values[(index - delta) % Weekday.values.length];
  }

  List<Weekday> genSequenceStartWithThis() => genSequence(this);
}
