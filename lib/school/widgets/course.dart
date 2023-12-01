import 'package:flutter/widgets.dart';
import 'package:sit/school/entity/school.dart';

class CourseIcon extends StatelessWidget {
  final String courseName;
  final double? size;
  static const kDefaultSize = 45.0;

  const CourseIcon({
    super.key,
    required this.courseName,
    this.size = kDefaultSize,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      CourseCategory.iconPathOf(courseName: courseName),
      width: size,
      height: size,
    );
  }
}
