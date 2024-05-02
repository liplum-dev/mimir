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

abstract class _$SitTimetableLessonPartStateCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitTimetableLessonPartState(...).copyWith(id: 12, name: "My name")
  /// ````
  SitTimetableLessonPartState call({
    int? index,
    SitTimetableLesson? type,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSitTimetableLessonPartState.copyWith(...)`.
class _$SitTimetableLessonPartStateCWProxyImpl implements _$SitTimetableLessonPartStateCWProxy {
  const _$SitTimetableLessonPartStateCWProxyImpl(this._value);

  final SitTimetableLessonPartState _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitTimetableLessonPartState(...).copyWith(id: 12, name: "My name")
  /// ````
  SitTimetableLessonPartState call({
    Object? index = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
  }) {
    return SitTimetableLessonPartState(
      index: index == const $CopyWithPlaceholder() || index == null
          ? _value.index
          // ignore: cast_nullable_to_non_nullable
          : index as int,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as SitTimetableLesson,
    );
  }
}

extension $SitTimetableLessonPartStateCopyWith on SitTimetableLessonPartState {
  /// Returns a callable class that can be used as follows: `instanceOfSitTimetableLessonPartState.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$SitTimetableLessonPartStateCWProxy get copyWith => _$SitTimetableLessonPartStateCWProxyImpl(this);
}
