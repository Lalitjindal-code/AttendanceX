import 'dart:convert';
import '../../../database/collections/academic_task_collection.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/attendance_history_collection.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/collections/profile_collection.dart';
import '../../../database/collections/semester_collection.dart';
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
    required this.profiles,
    required this.semesters,
    required this.subjects,
    required this.schedules,
    required this.attendanceRecords,
    required this.attendanceHistory,
    required this.tasks,
    required this.settings,
  });

  final BackupMetadata metadata;
  final List<Profile> profiles;
  final List<Semester> semesters;
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
        'profiles': profiles.map((x) => x.toMap()).toList(),
        'semesters': semesters.map((x) => x.toMap()).toList(),
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

    // Handle V1 legacy backups
    List<Profile> profiles = [];
    List<Semester> semesters = [];
    final settings = AppSettings.fromMap(data['settings'] ?? {});

    if (data.containsKey('profiles') && data.containsKey('semesters')) {
      profiles = List<Profile>.from(
          (data['profiles'] ?? []).map((x) => Profile.fromMap(x)));
      semesters = List<Semester>.from(
          (data['semesters'] ?? []).map((x) => Semester.fromMap(x)));
    } else {
      // Legacy V1 import: Create default profile and semester
      final p = Profile()
        ..id = 1
        ..name = 'Default Profile'
        ..isDefault = true
        ..defaultGoalPercentage = settings.defaultGoalPercentage
        ..medicalCountsAsPresent = settings.medicalCountsAsPresent
        ..gtMode = settings.gtMode
        ..notificationsEnabled = settings.notificationsEnabled
        ..dailyReminderEnabled = settings.dailyReminderEnabled
        ..dailyReminderTime = settings.dailyReminderTime
        ..lectureReminderMinutes = settings.lectureReminderMinutes
        ..defaultTaskReminderOffsets = settings.defaultTaskReminderOffsets;

      final s = Semester()
        ..id = 1
        ..profileId = 1
        ..name = 'Imported Semester'
        ..startDate = settings.semesterStartDate ?? DateTime(2020, 1, 1)
        ..endDate = settings.semesterEndDate;

      profiles.add(p);
      semesters.add(s);
    }

    final subjects = List<Subject>.from(
        (data['subjects'] ?? []).map((x) => Subject.fromMap(x)));
    final schedules = List<Schedule>.from(
        (data['schedules'] ?? []).map((x) => Schedule.fromMap(x)));
    final attendanceRecords = List<Attendance>.from(
        (data['attendanceRecords'] ?? []).map((x) => Attendance.fromMap(x)));
    final attendanceHistory = List<AttendanceHistory>.from(
        (data['attendanceHistory'] ?? [])
            .map((x) => AttendanceHistory.fromMap(x)));
    final tasks = List<AcademicTask>.from(
        (data['tasks'] ?? []).map((x) => AcademicTask.fromMap(x)));

    // Ensure all imported records belong to the default semester if not set
    if (!data.containsKey('semesters')) {
      for (var sub in subjects) {
        sub.semesterId = 1;
      }
      for (var sch in schedules) {
        sch.semesterId = 1;
      }
      for (var att in attendanceRecords) {
        att.semesterId = 1;
      }
      for (var hist in attendanceHistory) {
        hist.semesterId = 1;
      }
      for (var t in tasks) {
        t.semesterId = 1;
      }
    }

    return BackupModel(
      metadata: metadata,
      profiles: profiles,
      semesters: semesters,
      subjects: subjects,
      schedules: schedules,
      attendanceRecords: attendanceRecords,
      attendanceHistory: attendanceHistory,
      tasks: tasks,
      settings: settings,
    );
  }

  String toJson() => json.encode(toMap());

  factory BackupModel.fromJson(String source) =>
      BackupModel.fromMap(json.decode(source));
}
