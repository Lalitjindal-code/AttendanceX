class PlannerMetrics {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final int upcomingTasks;

  const PlannerMetrics({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.overdueTasks = 0,
    this.upcomingTasks = 0,
  });
  
  double get completionRate => totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
}
