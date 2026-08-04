import 'dart:convert';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/attendance_history_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../settings/models/app_settings.dart';

/// Metadata describing the backup file.
class BackupMetadata {
  BackupMetadata({
    required this.version,
    required this.appVersion,
    required this.databaseVersion,
    required this.createdAt,
    required this.platform,
    required this.checksum,
    required this.compressionType,
    this.reservedFutureFields = const {},
    this.cloudMetadata = const {},
  });

  final int version;
  final String appVersion;
  final int databaseVersion;
  final DateTime createdAt;
  final String platform;
  final String checksum;
  final String compressionType;
  final Map<String, dynamic> reservedFutureFields;
  final Map<String, dynamic> cloudMetadata;

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'appVersion': appVersion,
      'databaseVersion': databaseVersion,
      'createdAt': createdAt.toIso8601String(),
      'platform': platform,
      'checksum': checksum,
      'compressionType': compressionType,
      'reservedFutureFields': reservedFutureFields,
      'cloudMetadata': cloudMetadata,
    };
  }

  factory BackupMetadata.fromMap(Map<String, dynamic> map) {
    return BackupMetadata(
      version: map['version'] ?? 1,
      appVersion: map['appVersion'] ?? '1.0.0',
      databaseVersion: map['databaseVersion'] ?? 1,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      platform: map['platform'] ?? 'unknown',
      checksum: map['checksum'] ?? '',
      compressionType: map['compressionType'] ?? 'gzip',
      reservedFutureFields: map['reservedFutureFields'] ?? {},
      cloudMetadata: map['cloudMetadata'] ?? {},
    );
  }
}

/// The complete backup payload including metadata and data.
class BackupModel {
  BackupModel({
    required this.metadata,
    required this.subjects,
    required this.schedules,
    required this.attendanceRecords,
    required this.attendanceHistory,
    required this.tasks,
    required this.settings,
  });

  final BackupMetadata metadata;
  final List<Subject> subjects;
  final List<Schedule> schedules;
  final List<Attendance> attendanceRecords;
  final List<AttendanceHistory> attendanceHistory;
  final List<AcademicTask> tasks;
  final AppSettings settings;

  Map<String, dynamic> toMap() {
    return {
      'metadata': metadata.toMap(),
      'data': {
        'subjects': subjects.map((x) => x.toMap()).toList(),
        'schedules': schedules.map((x) => x.toMap()).toList(),
        'attendanceRecords': attendanceRecords.map((x) => x.toMap()).toList(),
        'attendanceHistory': attendanceHistory.map((x) => x.toMap()).toList(),
        'tasks': tasks.map((x) => x.toMap()).toList(),
        'settings': settings.toMap(),
      },
    };
  }

  factory BackupModel.fromMap(Map<String, dynamic> map) {
    final metadata = BackupMetadata.fromMap(map['metadata'] ?? {});
    final data = map['data'] ?? {};

    return BackupModel(
      metadata: metadata,
      subjects: List<Subject>.from(
          (data['subjects'] ?? []).map((x) => Subject.fromMap(x))),
      schedules: List<Schedule>.from(
          (data['schedules'] ?? []).map((x) => Schedule.fromMap(x))),
      attendanceRecords: List<Attendance>.from(
          (data['attendanceRecords'] ?? []).map((x) => Attendance.fromMap(x))),
      attendanceHistory: List<AttendanceHistory>.from(
          (data['attendanceHistory'] ?? [])
              .map((x) => AttendanceHistory.fromMap(x))),
      tasks: List<AcademicTask>.from(
          (data['tasks'] ?? []).map((x) => AcademicTask.fromMap(x))),
      settings: AppSettings.fromMap(data['settings'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory BackupModel.fromJson(String source) =>
      BackupModel.fromMap(json.decode(source));
}
