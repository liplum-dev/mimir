import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sit/init.dart';

import 'package:sit/school/entity/school.dart';
import 'package:sit/school/exam_result/init.dart';
import 'package:sit/session/pg_registration.dart';
import 'package:sit/session/ug_registration.dart';
import 'package:sit/settings/settings.dart';

import '../entity/course.dart';
import '../entity/timetable.dart';
import '../utils.dart';

class TimetableService {
  static const _undergraduateTimetableUrl = 'http://jwxt.sit.edu.cn/jwglxt/kbcx/xskbcx_cxXsgrkb.html';
  static const _postgraduateTimetableUrl =
      'http://gms.sit.edu.cn/epstar/yjs/T_PYGL_KWGL_WSXK/T_PYGL_KWGL_WSXK_XSKB_NEW.jsp';

  UgRegistrationSession get _ugRegSession => Init.ugRegSession;

  PgRegistrationSession get _pgRegSession => Init.pgRegSession;

  const TimetableService();

  Future<bool> checkConnectivity() {
    return _ugRegSession.checkConnectivity();
  }

  /// 获取本科生课表
  Future<SitTimetable> fetchUgTimetable(SemesterInfo info) async {
    final response = await _ugRegSession.request(
      _undergraduateTimetableUrl,
      options: Options(
        method: "POST",
      ),
      para: {'gnmkdm': 'N253508'},
      data: {
        // 学年名
        'xnm': info.exactYear.toString(),
        // 学期名
        'xqm': semesterToFormField(info.semester)
      },
    );
    final json = response.data;
    final List<dynamic> courseList = json['kbList'];
    final rawCourses = courseList.map((e) => UndergraduateCourseRaw.fromJson(e)).toList();
    final timetableEntity = parseUndergraduateTimetableFromCourseRaw(
      rawCourses,
      defaultCampus: Settings.campus,
    );
    return timetableEntity;
  }

  /// 获取研究生课表
  Future<SitTimetable> fetchPgTimetable(SemesterInfo info) async {
    final timetableRes = await _pgRegSession.request(
      _postgraduateTimetableUrl,
      options: Options(
        method: "POST",
      ),
      data: {
        "excel": "true",
        "XQDM": _toPgSemesterText(info),
      },
    );
    final scoreList = await ExamResultInit.pgService.fetchResultRawList();
    final courseList = parsePostgraduateCourseRawsFromHtml(timetableRes.data);
    completePostgraduateCourseRawsFromPostgraduateScoreRaws(courseList, scoreList);
    final timetableEntity = parsePostgraduateTimetableFromCourseRaw(
      courseList,
      defaultCampus: Settings.campus,
    );
    return timetableEntity;
  }

  String _toPgSemesterText(SemesterInfo info) {
    assert(info.semester != Semester.all);
    if (info.semester == Semester.term1) {
      return "${info.exactYear}09";
    } else {
      return "${info.exactYear + 1}02";
    }
  }

  Future<({DateTime start, DateTime end})?> getUgSemesterSpan() async {
    final res = await _ugRegSession.request(
      "http://jwxt.sit.edu.cn/jwglxt/xtgl/index_cxAreaFive.html",
      options: Options(
        method: "POST",
      ),
    );
    return _parseSemesterSpan(res.data);
  }

  static final _semesterSpanRe = RegExp(r"\((\S+)至(\S+)\)");
  static final _semesterSpanDateFormat = DateFormat("yyyy-MM-dd");

  ({DateTime start, DateTime end})? _parseSemesterSpan(String content) {
    final html = BeautifulSoup(content);
    final element = html.find("th", attrs: {"style": "text-align: center"});
    if (element == null) return null;
    final text = element.text;
    final match = _semesterSpanRe.firstMatch(text);
    if (match == null) return null;
    final start = _semesterSpanDateFormat.tryParse(match.group(1) ?? "");
    final end = _semesterSpanDateFormat.tryParse(match.group(2) ?? "");
    if (start == null || end == null) return null;
    return (start: start, end: end);
  }
}
