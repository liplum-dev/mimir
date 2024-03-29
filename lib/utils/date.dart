bool isLeapYear({
  required int year,
}) {
  if (year % 400 == 0) return true;
  if (year % 4 == 0 && year % 100 != 0) return true;
  return false;
}

int daysInMonth({
  required int year,
  required int month,
}) {
  assert(1 <= month && month <= 12, "month must be in [1,12]");
  return switch (month) {
    1 => 31,
    2 => isLeapYear(year: year) ? 29 : 28,
    3 => 31,
    4 => 30,
    5 => 31,
    6 => 30,
    7 => 31,
    8 => 31,
    9 => 30,
    10 => 31,
    11 => 30,
    12 => 31,
    _ => 30,
  };
}

List<int> daysInEachMonth({
  required int year,
}) {
  return [31, isLeapYear(year: year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
}
