// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimetablePosCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetablePos(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetablePos call({
    int? weekIndex,
    Weekday? weekday,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetablePos.copyWith(...)`.
class _$TimetablePosCWProxyImpl implements _$TimetablePosCWProxy {
  const _$TimetablePosCWProxyImpl(this._value);

  final TimetablePos _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetablePos(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetablePos call({
    Object? weekIndex = const $CopyWithPlaceholder(),
    Object? weekday = const $CopyWithPlaceholder(),
  }) {
    return TimetablePos(
      weekIndex: weekIndex == const $CopyWithPlaceholder() || weekIndex == null
          ? _value.weekIndex
          // ignore: cast_nullable_to_non_nullable
          : weekIndex as int,
      weekday: weekday == const $CopyWithPlaceholder() || weekday == null
          ? _value.weekday
          // ignore: cast_nullable_to_non_nullable
          : weekday as Weekday,
    );
  }
}

extension $TimetablePosCopyWith on TimetablePos {
  /// Returns a callable class that can be used as follows: `instanceOfTimetablePos.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetablePosCWProxy get copyWith => _$TimetablePosCWProxyImpl(this);
}
