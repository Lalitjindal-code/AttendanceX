import 'package:attendify/core/enums/lecture_type.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/isar_service.dart';
import 'package:attendify/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:attendify/services/widget_service.dart';

class ImportTimetableCseBlockchain1stSem {
  static Future<void> run() async {
    final isar = IsarService.instance.isar;
    final prefs = PreferencesService.instance;
    final semesterId = prefs.getInt('active_semester_id', defaultValue: 1);

    await isar.writeTxn(() async {
      final subjects = {
        'CH26101': Subject()
          ..name = 'CH26101 Applied Chemistry'
          ..facultyName = 'Dr. Namrata Rajawat'
          ..colorValue = Colors.indigo.toARGB32()
          ..credits = 4,
        'CS26101': Subject()
          ..name = 'CS26101 Fundamentals to Computer Science Engineering'
          ..facultyName = 'Prof. Garima Jain'
          ..colorValue = Colors.teal.toARGB32()
          ..credits = 4,
        'ME26101': Subject()
          ..name = 'ME26101 Fundamentals of Mechanical engineering'
          ..facultyName = 'Prof. Pankaj Sonkusare'
          ..colorValue = Colors.orange.toARGB32()
          ..credits = 3,
        'EI26101': Subject()
          ..name = 'EI26101 Fundamentals of Electronics Engineering'
          ..facultyName = 'Dr. Sweety Jain'
          ..colorValue = Colors.purple.toARGB32()
          ..credits = 3,
        'MA26101': Subject()
          ..name = 'MA26101 Linear Algebra and Calculus'
          ..facultyName = 'Dr Poonam Lata Sagar'
          ..colorValue = Colors.blue.toARGB32()
          ..credits = 3,
        'ME26102P': Subject()
          ..name = 'ME26102P Work Shop Practice'
          ..facultyName = 'Prof. Sanjay Jain'
          ..colorValue = Colors.red.toARGB32()
          ..credits = 2,
        'DS26101P': Subject()
          ..name = 'DS26101P Computer Workshop (Linux Lab)'
          ..facultyName = 'Prof. Ruchi Shrivastava'
          ..colorValue = Colors.green.toARGB32()
          ..credits = 2,
      };

      final savedSubjects = <String, Subject>{};

      for (final entry in subjects.entries) {
        entry.value.semesterId = semesterId;
        final existingList = await isar.subjects
            .filter()
            .nameEqualTo(entry.value.name)
            .and()
            .semesterIdEqualTo(semesterId)
            .findAll();
        final existing = existingList.isEmpty ? null : existingList.first;
        if (existing == null) {
          final id = await isar.subjects.put(entry.value);
          savedSubjects[entry.key] = entry.value..id = id;
        } else {
          savedSubjects[entry.key] = existing;
        }
      }

      Future<void> addSchedule({
        required String subjectKey,
        required int day,
        required String startTime,
        required String endTime,
        required String? room,
        required LectureType type,
        String? facultyOverride,
      }) async {
        final subject = savedSubjects[subjectKey]!;
        final s = Schedule()
          ..semesterId = semesterId
          ..subjectId = subject.id
          ..dayOfWeek = day
          ..startTime = startTime
          ..endTime = endTime
          ..room = room
          ..type = type
          ..facultyOverride = facultyOverride;

        await isar.schedules.put(s);
      }

      await isar.schedules.filter().semesterIdEqualTo(semesterId).deleteAll();

      // MONDAY (Day 1)
      await addSchedule(
          subjectKey: 'CH26101',
          day: 1,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'MA26101',
          day: 1,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'ME26101',
          day: 1,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'DS26101P',
          day: 1,
          startTime: '15:30',
          endTime: '17:30',
          room: 'VNCC Z-2',
          type: LectureType.lab);

      // TUESDAY (Day 2)
      await addSchedule(
          subjectKey: 'CH26101',
          day: 2,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'MA26101',
          day: 2,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'CS26101',
          day: 2,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No. 206',
          type: LectureType.lecture);

      // WEDNESDAY (Day 3)
      await addSchedule(
          subjectKey: 'CS26101',
          day: 3,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'EI26101',
          day: 3,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'CH26101',
          day: 3,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'ME26102P',
          day: 3,
          startTime: '14:00',
          endTime: '18:00',
          room: 'Workshop',
          type: LectureType.lab);

      // THURSDAY (Day 4)
      await addSchedule(
          subjectKey: 'CS26101',
          day: 4,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'ME26101',
          day: 4,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'EI26101',
          day: 4,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'CS26101',
          day: 4,
          startTime: '14:30',
          endTime: '16:30',
          room: 'VNCC Z-1',
          type: LectureType.lab);

      // FRIDAY (Day 5)
      await addSchedule(
          subjectKey: 'ME26101',
          day: 5,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'EI26101',
          day: 5,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'MA26101',
          day: 5,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No. 206',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'CH26101',
          day: 5,
          startTime: '14:30',
          endTime: '17:30',
          room: 'Chemistry Lab',
          type: LectureType.lab);
    });

    await prefs.setString(PreferencesService.keySemesterStart, '2026-08-17');
    WidgetService.instance.updateWidget();
  }
}
