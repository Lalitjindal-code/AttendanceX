class AttendanceForecast {
  final double currentPercentage;
  final double projectedPercentageIfAttendNext;
  final double projectedPercentageIfBunkNext;
  final int classesNeededToReachGoal;
  final int safeBunksRemaining;

  const AttendanceForecast({
    required this.currentPercentage,
    required this.projectedPercentageIfAttendNext,
    required this.projectedPercentageIfBunkNext,
    required this.classesNeededToReachGoal,
    required this.safeBunksRemaining,
  });
}
