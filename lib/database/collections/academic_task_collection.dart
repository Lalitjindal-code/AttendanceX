import 'package:isar/isar.dart';
import '../../core/enums/task_type.dart';
import '../../core/enums/task_priority.dart';
import '../../core/enums/task_status.dart';

part 'academic_task_collection.g.dart';

@collection
class AcademicTask {
  AcademicTask();

  /// Auto-incremented primary key.
  Id id = Isar.autoIncrement;

  /// Foreign key referencing [Semester.id].
  @Index()
  int semesterId = 0;

  /// The title of the task. Max 100 characters.
  late String title;

  String? description;

  @Index()
  int subjectId = 0;

  int? facultyId;

  @Enumerated(EnumType.name)
  late TaskType type;

  @Enumerated(EnumType.name)
  TaskPriority priority = TaskPriority.medium;

  @Enumerated(EnumType.name)
  TaskStatus status = TaskStatus.pending;

  @Index()
  late DateTime dueDate;

  /// Stored as 'HH:mm' format
  String? dueTime;

  /// Estimated duration in minutes
  int? estimatedDuration;

  /// Future-ready: Cron string or simple rules like 'weekly'
  String? repeatRule;

  String? notes;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  DateTime? completedAt;

  /// Future-ready: File paths or URIs
  List<String> attachments = [];

  /// Future-ready: Checklist, URLs, etc.
  List<String> submissionUrls = [];

  /// List of minutes before the due date/time to trigger a reminder
  List<int> notificationOffsets = [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semesterId': semesterId,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'facultyId': facultyId,
      'type': type.name,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'dueTime': dueTime,
      'estimatedDuration': estimatedDuration,
      'repeatRule': repeatRule,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'attachments': attachments,
      'submissionUrls': submissionUrls,
      'notificationOffsets': notificationOffsets,
    };
  }

  factory AcademicTask.fromMap(Map<String, dynamic> map) {
    return AcademicTask()
      ..id = map['id'] ?? Isar.autoIncrement
      ..semesterId = map['semesterId'] ?? 0
      ..title = map['title'] ?? 'Untitled Task'
      ..description = map['description']
      ..subjectId = map['subjectId'] ?? 0
      ..facultyId = map['facultyId']
      ..type = TaskType.values.firstWhere((e) => e.name == map['type'],
          orElse: () => TaskType.assignment)
      ..priority = TaskPriority.values.firstWhere(
          (e) => e.name == map['priority'],
          orElse: () => TaskPriority.medium)
      ..status = TaskStatus.values.firstWhere((e) => e.name == map['status'],
          orElse: () => TaskStatus.pending)
      ..dueDate = map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : DateTime.now()
      ..dueTime = map['dueTime']
      ..estimatedDuration = map['estimatedDuration']
      ..repeatRule = map['repeatRule']
      ..notes = map['notes']
      ..createdAt = map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now()
      ..updatedAt = map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : DateTime.now()
      ..completedAt = map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null
      ..attachments = List<String>.from(map['attachments'] ?? [])
      ..submissionUrls = List<String>.from(map['submissionUrls'] ?? [])
      ..notificationOffsets = List<int>.from(map['notificationOffsets'] ?? []);
  }
}
