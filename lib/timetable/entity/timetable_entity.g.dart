// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_entity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SitTimetableDayStateCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitTimetableDayState(...).copyWith(id: 12, name: "My name")
  /// ````
  SitTimetableDayState call({
    List<SitTimetableLesson>? lessons,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSitTimetableDayState.copyWith(...)`.
class _$SitTimetableDayStateCWProxyImpl implements _$SitTimetableDayStateCWProxy {
  const _$SitTimetableDayStateCWProxyImpl(this._value);

  final SitTimetableDayState _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitTimetableDayState(...).copyWith(id: 12, name: "My name")
  /// ````
  SitTimetableDayState call({
    Object? lessons = const $CopyWithPlaceholder(),
  }) {
    return SitTimetableDayState(
      lessons: lessons == const $CopyWithPlaceholder() || lessons == null
          ? _value.lessons
          // ignore: cast_nullable_to_non_nullable
          : lessons as List<SitTimetableLesson>,
    );
  }
}

extension $SitTimetableDayStateCopyWith on SitTimetableDayState {
  /// Returns a callable class that can be used as follows: `instanceOfSitTimetableDayState.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$SitTimetableDayStateCWProxy get copyWith => _$SitTimetableDayStateCWProxyImpl(this);
}
