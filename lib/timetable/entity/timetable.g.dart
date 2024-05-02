// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SitTimetableCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitTimetable(...).copyWith(id: 12, name: "My name")
  /// ````
  SitTimetable call({
    Map<String, SitCourse>? courses,
    int? lastCourseKey,
    String? name,
    DateTime? startDate,
    Campus? campus,
    int? schoolYear,
    Semester? semester,
    DateTime? lastModified,
    List<TimetablePatchEntry>? patches,
    String? signature,
    int? version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSitTimetable.copyWith(...)`.
class _$SitTimetableCWProxyImpl implements _$SitTimetableCWProxy {
  const _$SitTimetableCWProxyImpl(this._value);

  final SitTimetable _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitTimetable(...).copyWith(id: 12, name: "My name")
  /// ````
  SitTimetable call({
    Object? courses = const $CopyWithPlaceholder(),
    Object? lastCourseKey = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? campus = const $CopyWithPlaceholder(),
    Object? schoolYear = const $CopyWithPlaceholder(),
    Object? semester = const $CopyWithPlaceholder(),
    Object? lastModified = const $CopyWithPlaceholder(),
    Object? patches = const $CopyWithPlaceholder(),
    Object? signature = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return SitTimetable(
      courses: courses == const $CopyWithPlaceholder() || courses == null
          ? _value.courses
          // ignore: cast_nullable_to_non_nullable
          : courses as Map<String, SitCourse>,
      lastCourseKey: lastCourseKey == const $CopyWithPlaceholder() || lastCourseKey == null
          ? _value.lastCourseKey
          // ignore: cast_nullable_to_non_nullable
          : lastCourseKey as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      startDate: startDate == const $CopyWithPlaceholder() || startDate == null
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as DateTime,
      campus: campus == const $CopyWithPlaceholder() || campus == null
          ? _value.campus
          // ignore: cast_nullable_to_non_nullable
          : campus as Campus,
      schoolYear: schoolYear == const $CopyWithPlaceholder() || schoolYear == null
          ? _value.schoolYear
          // ignore: cast_nullable_to_non_nullable
          : schoolYear as int,
      semester: semester == const $CopyWithPlaceholder() || semester == null
          ? _value.semester
          // ignore: cast_nullable_to_non_nullable
          : semester as Semester,
      lastModified: lastModified == const $CopyWithPlaceholder() || lastModified == null
          ? _value.lastModified
          // ignore: cast_nullable_to_non_nullable
          : lastModified as DateTime,
      patches: patches == const $CopyWithPlaceholder() || patches == null
          ? _value.patches
          // ignore: cast_nullable_to_non_nullable
          : patches as List<TimetablePatchEntry>,
      signature: signature == const $CopyWithPlaceholder() || signature == null
          ? _value.signature
          // ignore: cast_nullable_to_non_nullable
          : signature as String,
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $SitTimetableCopyWith on SitTimetable {
  /// Returns a callable class that can be used as follows: `instanceOfSitTimetable.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$SitTimetableCWProxy get copyWith => _$SitTimetableCWProxyImpl(this);
}

abstract class _$SitCourseCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitCourse(...).copyWith(id: 12, name: "My name")
  /// ````
  SitCourse call({
    int? courseKey,
    String? courseName,
    String? courseCode,
    String? classCode,
    String? place,
    TimetableWeekIndices? weekIndices,
    ({int end, int start})? timeslots,
    double? courseCredit,
    int? dayIndex,
    List<String>? teachers,
    bool? hidden,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSitCourse.copyWith(...)`.
class _$SitCourseCWProxyImpl implements _$SitCourseCWProxy {
  const _$SitCourseCWProxyImpl(this._value);

  final SitCourse _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// SitCourse(...).copyWith(id: 12, name: "My name")
  /// ````
  SitCourse call({
    Object? courseKey = const $CopyWithPlaceholder(),
    Object? courseName = const $CopyWithPlaceholder(),
    Object? courseCode = const $CopyWithPlaceholder(),
    Object? classCode = const $CopyWithPlaceholder(),
    Object? place = const $CopyWithPlaceholder(),
    Object? weekIndices = const $CopyWithPlaceholder(),
    Object? timeslots = const $CopyWithPlaceholder(),
    Object? courseCredit = const $CopyWithPlaceholder(),
    Object? dayIndex = const $CopyWithPlaceholder(),
    Object? teachers = const $CopyWithPlaceholder(),
    Object? hidden = const $CopyWithPlaceholder(),
  }) {
    return SitCourse(
      courseKey: courseKey == const $CopyWithPlaceholder() || courseKey == null
          ? _value.courseKey
          // ignore: cast_nullable_to_non_nullable
          : courseKey as int,
      courseName: courseName == const $CopyWithPlaceholder() || courseName == null
          ? _value.courseName
          // ignore: cast_nullable_to_non_nullable
          : courseName as String,
      courseCode: courseCode == const $CopyWithPlaceholder() || courseCode == null
          ? _value.courseCode
          // ignore: cast_nullable_to_non_nullable
          : courseCode as String,
      classCode: classCode == const $CopyWithPlaceholder() || classCode == null
          ? _value.classCode
          // ignore: cast_nullable_to_non_nullable
          : classCode as String,
      place: place == const $CopyWithPlaceholder() || place == null
          ? _value.place
          // ignore: cast_nullable_to_non_nullable
          : place as String,
      weekIndices: weekIndices == const $CopyWithPlaceholder() || weekIndices == null
          ? _value.weekIndices
          // ignore: cast_nullable_to_non_nullable
          : weekIndices as TimetableWeekIndices,
      timeslots: timeslots == const $CopyWithPlaceholder() || timeslots == null
          ? _value.timeslots
          // ignore: cast_nullable_to_non_nullable
          : timeslots as ({int end, int start}),
      courseCredit: courseCredit == const $CopyWithPlaceholder() || courseCredit == null
          ? _value.courseCredit
          // ignore: cast_nullable_to_non_nullable
          : courseCredit as double,
      dayIndex: dayIndex == const $CopyWithPlaceholder() || dayIndex == null
          ? _value.dayIndex
          // ignore: cast_nullable_to_non_nullable
          : dayIndex as int,
      teachers: teachers == const $CopyWithPlaceholder() || teachers == null
          ? _value.teachers
          // ignore: cast_nullable_to_non_nullable
          : teachers as List<String>,
      hidden: hidden == const $CopyWithPlaceholder() || hidden == null
          ? _value.hidden
          // ignore: cast_nullable_to_non_nullable
          : hidden as bool,
    );
  }
}

extension $SitCourseCopyWith on SitCourse {
  /// Returns a callable class that can be used as follows: `instanceOfSitCourse.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$SitCourseCWProxy get copyWith => _$SitCourseCWProxyImpl(this);
}

abstract class _$TimetableWeekIndexCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableWeekIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableWeekIndex call({
    TimetableWeekIndexType? type,
    ({int end, int start})? range,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetableWeekIndex.copyWith(...)`.
class _$TimetableWeekIndexCWProxyImpl implements _$TimetableWeekIndexCWProxy {
  const _$TimetableWeekIndexCWProxyImpl(this._value);

  final TimetableWeekIndex _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableWeekIndex(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableWeekIndex call({
    Object? type = const $CopyWithPlaceholder(),
    Object? range = const $CopyWithPlaceholder(),
  }) {
    return TimetableWeekIndex(
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as TimetableWeekIndexType,
      range: range == const $CopyWithPlaceholder() || range == null
          ? _value.range
          // ignore: cast_nullable_to_non_nullable
          : range as ({int end, int start}),
    );
  }
}

extension $TimetableWeekIndexCopyWith on TimetableWeekIndex {
  /// Returns a callable class that can be used as follows: `instanceOfTimetableWeekIndex.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableWeekIndexCWProxy get copyWith => _$TimetableWeekIndexCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SitTimetable _$SitTimetableFromJson(Map<String, dynamic> json) => SitTimetable(
      courses: (json['courses'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, SitCourse.fromJson(e as Map<String, dynamic>)),
      ),
      lastCourseKey: (json['lastCourseKey'] as num).toInt(),
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      campus: $enumDecodeNullable(_$CampusEnumMap, json['campus'], unknownValue: Campus.fengxian) ?? _defaultCampus(),
      schoolYear: (json['schoolYear'] as num).toInt(),
      semester: $enumDecode(_$SemesterEnumMap, json['semester']),
      lastModified: json['lastModified'] == null ? _kLastModified() : DateTime.parse(json['lastModified'] as String),
      patches: json['patches'] == null ? const [] : _patchesFromJson(json['patches'] as List?),
      signature: json['signature'] as String? ?? "",
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$SitTimetableToJson(SitTimetable instance) => <String, dynamic>{
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'campus': _$CampusEnumMap[instance.campus]!,
      'schoolYear': instance.schoolYear,
      'semester': _$SemesterEnumMap[instance.semester]!,
      'lastCourseKey': instance.lastCourseKey,
      'signature': instance.signature,
      'courses': instance.courses,
      'lastModified': instance.lastModified.toIso8601String(),
      'version': instance.version,
      'patches': instance.patches,
    };

const _$CampusEnumMap = {
  Campus.fengxian: 'fengxian',
  Campus.xuhui: 'xuhui',
};

const _$SemesterEnumMap = {
  Semester.all: 'all',
  Semester.term1: 'term1',
  Semester.term2: 'term2',
};

SitCourse _$SitCourseFromJson(Map<String, dynamic> json) => SitCourse(
      courseKey: (json['courseKey'] as num).toInt(),
      courseName: json['courseName'] as String,
      courseCode: json['courseCode'] as String,
      classCode: json['classCode'] as String,
      place: json['place'] as String,
      weekIndices: TimetableWeekIndices.fromJson(json['weekIndices'] as Map<String, dynamic>),
      timeslots: _$recordConvert(
        json['timeslots'],
        ($jsonValue) => (
          end: ($jsonValue['end'] as num).toInt(),
          start: ($jsonValue['start'] as num).toInt(),
        ),
      ),
      courseCredit: (json['courseCredit'] as num).toDouble(),
      dayIndex: (json['dayIndex'] as num).toInt(),
      teachers: (json['teachers'] as List<dynamic>).map((e) => e as String).toList(),
      hidden: json['hidden'] as bool? ?? false,
    );

Map<String, dynamic> _$SitCourseToJson(SitCourse instance) => <String, dynamic>{
      'courseKey': instance.courseKey,
      'courseName': instance.courseName,
      'courseCode': instance.courseCode,
      'classCode': instance.classCode,
      'place': instance.place,
      'weekIndices': instance.weekIndices,
      'timeslots': <String, dynamic>{
        'end': instance.timeslots.end,
        'start': instance.timeslots.start,
      },
      'courseCredit': instance.courseCredit,
      'dayIndex': instance.dayIndex,
      'teachers': instance.teachers,
      'hidden': instance.hidden,
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

TimetableWeekIndex _$TimetableWeekIndexFromJson(Map<String, dynamic> json) => TimetableWeekIndex(
      type: $enumDecode(_$TimetableWeekIndexTypeEnumMap, json['type']),
      range: _$recordConvert(
        json['range'],
        ($jsonValue) => (
          end: ($jsonValue['end'] as num).toInt(),
          start: ($jsonValue['start'] as num).toInt(),
        ),
      ),
    );

Map<String, dynamic> _$TimetableWeekIndexToJson(TimetableWeekIndex instance) => <String, dynamic>{
      'type': _$TimetableWeekIndexTypeEnumMap[instance.type]!,
      'range': <String, dynamic>{
        'end': instance.range.end,
        'start': instance.range.start,
      },
    };

const _$TimetableWeekIndexTypeEnumMap = {
  TimetableWeekIndexType.all: 'all',
  TimetableWeekIndexType.odd: 'odd',
  TimetableWeekIndexType.even: 'even',
};

TimetableWeekIndices _$TimetableWeekIndicesFromJson(Map<String, dynamic> json) => TimetableWeekIndices(
      (json['indices'] as List<dynamic>).map((e) => TimetableWeekIndex.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$TimetableWeekIndicesToJson(TimetableWeekIndices instance) => <String, dynamic>{
      'indices': instance.indices,
    };
