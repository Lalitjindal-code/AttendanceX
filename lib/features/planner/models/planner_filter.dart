import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';

class PlannerFilter {
  final int? subjectId;
  final TaskPriority? priority;
  final TaskStatus? status;
  final bool hideCompleted;

  const PlannerFilter({
    this.subjectId,
    this.priority,
    this.status,
    this.hideCompleted = true,
  });

  PlannerFilter copyWith({
    int? subjectId,
    bool clearSubject = false,
    TaskPriority? priority,
    bool clearPriority = false,
    TaskStatus? status,
    bool clearStatus = false,
    bool? hideCompleted,
  }) {
    return PlannerFilter(
      subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
      priority: clearPriority ? null : (priority ?? this.priority),
      status: clearStatus ? null : (status ?? this.status),
      hideCompleted: hideCompleted ?? this.hideCompleted,
    );
  }

  bool get isEmpty => subjectId == null && priority == null && status == null;
}
