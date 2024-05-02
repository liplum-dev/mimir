import 'package:sit/entity/campus.dart';
import 'package:sit/school/entity/school.dart';
import '../entity/timetable.dart';
import 'school.dart';

class DemoTimetableService implements TimetableService {
  const DemoTimetableService();

  @override
  Future<bool> checkConnectivity() async {
    return true;
  }

  @override
  Future<SitTimetable> fetchUgTimetable(SemesterInfo info) async {
    var key = 0;
    return SitTimetable(
      campus: Campus.fengxian,
      courses: {
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活开发实训',
          courseCode: 'dev',
          classCode: '001',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 0, end: 2),
          courseCredit: 6.0,
          dayIndex: 0,
          teachers: [],
        ),
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活运维实训',
          courseCode: 'ops',
          classCode: '002',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 5, end: 7),
          courseCredit: 6.0,
          dayIndex: 2,
          teachers: [],
        ),
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活设计实训',
          courseCode: 'design',
          classCode: '003',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 2, end: 4),
          courseCredit: 3.0,
          dayIndex: 4,
          teachers: [],
        ),
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活部署实训',
          courseCode: 'deploy',
          classCode: '004',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 0, end: 1),
          courseCredit: 1.0,
          dayIndex: 3,
          teachers: [],
        ),
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活管理实训',
          courseCode: 'management',
          classCode: '005',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 5, end: 6),
          courseCredit: 1.0,
          dayIndex: 1,
          teachers: [],
        ),
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活会议',
          courseCode: 'meeting',
          classCode: '006',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 2, end: 3),
          courseCredit: 1.0,
          dayIndex: 1,
          teachers: [],
        ),
        "$key": SitCourse(
          courseKey: key++,
          courseName: '小应生活国际化实训',
          courseCode: 'i18n',
          classCode: '007',
          place: '小应生活实验室',
          weekIndices: const TimetableWeekIndices([
            TimetableWeekIndex.all((start: 0, end: 19)),
          ]),
          timeslots: (start: 1, end: 2),
          courseCredit: 1.0,
          dayIndex: 2,
          teachers: [],
        ),
      },
      lastCourseKey: key,
      name: "小应生活的课程表",
      startDate: DateTime.now(),
      schoolYear: info.exactYear,
      semester: info.semester,
      lastModified: DateTime.now(),
    );
  }

  @override
  Future<SitTimetable> fetchPgTimetable(SemesterInfo info) async {
    return fetchUgTimetable(info);
  }

  @override
  Future<({DateTime start, DateTime end})?> getUgSemesterSpan() async {
    final now = DateTime.now();
    return (start: now, end: now.copyWith(month: now.month + 4));
  }
}
