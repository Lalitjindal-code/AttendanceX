import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:isar/isar.dart';

import '../database/collections/attendance_collection.dart';
import '../database/collections/schedule_collection.dart';
import '../database/collections/subject_collection.dart';
import '../database/isar_service.dart';

/// Key used by both Flutter and Kotlin to identify the widget data entry.
const String _kWidgetDataKey = 'attendify_widget_data';

/// App group identifier required by [HomeWidget] on iOS.
/// On Android this value is unused but still required by the API.
const String _kAppGroupId = 'group.com.lalitjindal.attendify';

/// Android widget provider class name (used by [HomeWidget.updateWidget]).
const String _kAndroidWidgetName = 'AttendifyWidgetReceiver';

/// Singleton service that pushes schedule data to the home screen widget.
///
/// Call [updateWidget] whenever schedule, subject, or attendance data changes.
class WidgetService {
  WidgetService._();
  static final WidgetService instance = WidgetService._();

  bool _initialized = false;

  /// Must be called once (e.g., in [main]) before [updateWidget].
  Future<void> initialize() async {
    if (_initialized) return;
    await HomeWidget.setAppGroupId(_kAppGroupId);
    _initialized = true;
  }

  /// Reads today's schedule + subjects + attendance from Isar and pushes
  /// the serialized JSON to SharedPreferences so the Glance widget can render.
  Future<void> updateWidget() async {
    try {
      final isar = IsarService.instance.isar;
      final now = DateTime.now();
      final todayWeekday = now.weekday; // 1=Mon … 7=Sun

      // Fetch ALL schedule slots for the entire week
      final schedules = await isar.schedules
          .where()
          .sortByStartTime()
          .findAll();

      // Fetch all active subjects (for name + color lookup)
      final subjects = await isar.subjects
          .filter()
          .isActiveEqualTo(true)
          .findAll();

      // Fetch today's attendance records
      final todayUtc = DateTime.utc(now.year, now.month, now.day);
      final allAttendances = await isar.attendances.where().findAll();
      final todayAttendances = allAttendances
          .where((a) =>
              a.date.year == todayUtc.year &&
              a.date.month == todayUtc.month &&
              a.date.day == todayUtc.day)
          .toList();

      // Build per-subject attendance percentages & overall attendance
      final Map<int, double> subjectPercentages = {};
      int totalPresentAll = 0;
      int totalLecturesAll = 0;
      
      for (final subject in subjects) {
        final subjectRecords =
            allAttendances.where((a) => a.subjectId == subject.id).toList();
        final total = subjectRecords
            .where((a) =>
                a.status.name == 'present' || a.status.name == 'absent')
            .length;
        final present =
            subjectRecords.where((a) => a.status.name == 'present').length;
            
        if (subject.isIncludedInOverall) {
          totalLecturesAll += total;
          totalPresentAll += present;
        }
            
        subjectPercentages[subject.id] =
            total == 0 ? 0.0 : (present / total) * 100.0;
      }
      
      final overallAttendance = totalLecturesAll == 0 
          ? 0.0 
          : (totalPresentAll / totalLecturesAll) * 100.0;

      // Build the card list
      final List<Map<String, dynamic>> cards = [];
      for (final schedule in schedules) {
        final subject =
            subjects.firstWhereOrNull((s) => s.id == schedule.subjectId);
        if (subject == null) continue;

        final attendanceForSlot = todayAttendances
            .firstWhereOrNull((a) => a.scheduleId == schedule.id);

        cards.add({
          'scheduleId': schedule.id,
          'dayOfWeek': schedule.dayOfWeek, // 1=Mon .. 7=Sun
          'subjectName': subject.name,
          'subjectColor': subject.colorValue,
          'startTime': schedule.startTime,
          'endTime': schedule.endTime,
          'room': schedule.room,
          'type': schedule.type.name,
          'attendanceStatus': (schedule.dayOfWeek == todayWeekday) ? (attendanceForSlot?.status.name ?? 'pending') : 'pending',
          'attendancePercent':
              (subjectPercentages[subject.id] ?? 0.0).toStringAsFixed(1),
          'goalPercent': subject.goalPercentage.toStringAsFixed(1),
        });
      }

      final payload = json.encode({
        'cards': cards,
        'overallAttendance': overallAttendance.toStringAsFixed(1),
        'updatedAt': now.millisecondsSinceEpoch,
      });

      await HomeWidget.saveWidgetData<String>(_kWidgetDataKey, payload);
      await HomeWidget.updateWidget(androidName: _kAndroidWidgetName);
    } catch (e) {
      // Widget update failing should never crash the app
    }
  }
}

// Extension on [Iterable] for null-safe first-where lookup.
extension _IterableExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
