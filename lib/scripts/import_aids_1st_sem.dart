import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../core/enums/lecture_type.dart';
import '../database/collections/schedule_collection.dart';
import '../database/collections/subject_collection.dart';
import '../database/isar_service.dart';
import '../services/preferences_service.dart';
import '../services/widget_service.dart';

class ImportAids1stSem {
  static Future<void> run() async {
    final isar = IsarService.instance.isar;
    final prefs = PreferencesService.instance;
    final semesterId = prefs.getInt('active_semester_id', defaultValue: 1);

    await isar.writeTxn(() async {
      // 1. Create Subjects
      final subjects = {
        'CH26101': Subject()
          ..name = 'Applied Chemistry'
          ..facultyName = 'Dr. Raje Sengar'
          ..colorValue = Colors.teal.toARGB32(),
        'CS26101': Subject()
          ..name = 'Fundamentals to Computer Science Engineering'
          ..facultyName = 'Prof. Sheena Kumar'
          ..colorValue = Colors.blue.toARGB32(),
        'ME26101': Subject()
          ..name = 'Fundamentals of Mechanical engineering'
          ..facultyName = 'Prof. Neeraj Sen'
          ..colorValue = Colors.orange.toARGB32(),
        'EI26101': Subject()
          ..name = 'Fundamentals of Electronics Engineering'
          ..facultyName = 'Prof. Niraj Kumar'
          ..colorValue = Colors.deepPurple.toARGB32(),
        'MA26101': Subject()
          ..name = 'Linear Algebra and Calculus'
          ..facultyName = 'Dr Poonam Lata Sagar'
          ..colorValue = Colors.indigo.toARGB32(),
        'ME26102P': Subject()
          ..name = 'Work Shop Practice'
          ..facultyName = 'Prof. Sanjay Jain'
          ..colorValue = Colors.brown.toARGB32(),
        'DS26101P': Subject()
          ..name = 'Computer Workshop (Linux Lab)'
          ..facultyName = 'Dr. Smriti Dubey'
          ..colorValue = Colors.green.toARGB32(),
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
        required String subjectCode,
        required int day,
        required String startTime,
        required String endTime,
        LectureType type = LectureType.lecture,
        String? roomOverride,
      }) async {
        final subject = savedSubjects[subjectCode]!;
        final s = Schedule()
          ..semesterId = semesterId
          ..subjectId = subject.id
          ..dayOfWeek = day
          ..startTime = startTime
          ..endTime = endTime
          ..room = roomOverride ?? '206'
          ..type = type;

        await isar.schedules.put(s);
      }

      await isar.schedules.filter().semesterIdEqualTo(semesterId).deleteAll();

      // MONDAY (1)
      await addSchedule(subjectCode: 'DS26101P', day: 1, startTime: '11:30', endTime: '13:30', type: LectureType.lab, roomOverride: 'VNCC Z-2');
      await addSchedule(subjectCode: 'EI26101', day: 1, startTime: '14:30', endTime: '15:30');
      await addSchedule(subjectCode: 'CH26101', day: 1, startTime: '15:30', endTime: '16:30');
      await addSchedule(subjectCode: 'CS26101', day: 1, startTime: '16:30', endTime: '17:30');

      // TUESDAY (2)
      await addSchedule(subjectCode: 'CS26101', day: 2, startTime: '14:30', endTime: '15:30');
      await addSchedule(subjectCode: 'MA26101', day: 2, startTime: '15:30', endTime: '16:30');
      await addSchedule(subjectCode: 'ME26101', day: 2, startTime: '16:30', endTime: '17:30');

      // WEDNESDAY (3)
      await addSchedule(subjectCode: 'CH26101', day: 3, startTime: '10:30', endTime: '12:30', type: LectureType.lab, roomOverride: 'Chemistry Lab');
      await addSchedule(subjectCode: 'MA26101', day: 3, startTime: '14:30', endTime: '15:30');
      await addSchedule(subjectCode: 'CH26101', day: 3, startTime: '15:30', endTime: '16:30');
      await addSchedule(subjectCode: 'EI26101', day: 3, startTime: '16:30', endTime: '17:30');

      // THURSDAY (4)
      await addSchedule(subjectCode: 'CS26101', day: 4, startTime: '11:30', endTime: '13:30', type: LectureType.lab, roomOverride: 'VNCC Z-1');
      await addSchedule(subjectCode: 'ME26101', day: 4, startTime: '14:30', endTime: '15:30');
      await addSchedule(subjectCode: 'CH26101', day: 4, startTime: '15:30', endTime: '16:30');
      await addSchedule(subjectCode: 'CS26101', day: 4, startTime: '16:30', endTime: '17:30');

      // FRIDAY (5)
      await addSchedule(subjectCode: 'ME26102P', day: 5, startTime: '10:00', endTime: '14:00', type: LectureType.lab, roomOverride: 'Workshop');
      await addSchedule(subjectCode: 'ME26101', day: 5, startTime: '14:30', endTime: '15:30');
      await addSchedule(subjectCode: 'MA26101', day: 5, startTime: '15:30', endTime: '16:30');
      await addSchedule(subjectCode: 'EI26101', day: 5, startTime: '16:30', endTime: '17:30');
    });

    await prefs.setString(PreferencesService.keySemesterStart, '2026-08-17');
    WidgetService.instance.updateWidget();
  }
}
