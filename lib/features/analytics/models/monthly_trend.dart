class MonthlyTrend {
  final int year;
  final int month;
  final int presentCount;
  final int totalCount;
  final double percentage;

  const MonthlyTrend({
    required this.year,
    required this.month,
    required this.presentCount,
    required this.totalCount,
    required this.percentage,
  });
}
