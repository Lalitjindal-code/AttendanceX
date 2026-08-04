class DayOfWeekTrend {
  final int weekday; // 1 = Monday, 7 = Sunday
  final int presentCount;
  final int totalCount;
  final double percentage;

  const DayOfWeekTrend({
    required this.weekday,
    required this.presentCount,
    required this.totalCount,
    required this.percentage,
  });
}
