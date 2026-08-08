import 'package:attendify/core/enums/lecture_type.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/isar_service.dart';
import 'package:attendify/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class ImportTimetable {
  static Future<void> run() async {
    final isar = IsarService.instance.isar;
    final prefs = PreferencesService.instance;
    final semesterId = prefs.getInt('active_semester_id', defaultValue: 1);

    await isar.writeTxn(() async {
      final subjects = {
        'AI-302': Subject()
          ..name = 'AI-302 Artificial Intelligence'
          ..facultyName = 'Dr. Rashi Kumar'
          ..colorValue = Colors.indigo.toARGB32()
          ..credits = 3,
        'AI-303': Subject()
          ..name = 'AI-303 Object Oriented Programming with Java'
          ..facultyName = 'Dr. Shaila Chugh'
          ..colorValue = Colors.teal.toARGB32()
          ..credits = 4,
        'AI-304': Subject()
          ..name = 'AI-304 Operating System'
          ..facultyName = 'Prof. Sumeet Dhilon'
          ..colorValue = Colors.orange.toARGB32()
          ..credits = 4,
        'AI-305': Subject()
          ..name = 'AI-305 Computer System Organization'
          ..facultyName = 'Prof. Jyothi Sonkar'
          ..colorValue = Colors.purple.toARGB32()
          ..credits = 3,
        'AI-306': Subject()
          ..name = 'AI-306 Web Application Development'
          ..facultyName = 'SMD'
          ..colorValue = Colors.blue.toARGB32()
          ..credits = 3,
        'MAB-301': Subject()
          ..name = 'MAB-301 Discrete Mathematics'
          ..facultyName = 'Prof. Poonam Lata Prabhakar'
          ..colorValue = Colors.red.toARGB32()
          ..credits = 3,
        'AI-307': Subject()
          ..name = 'AI-307 Internship-I'
          ..facultyName =
              'Prof. Jyothi Sonkar, Prof. Ankur Mishra, Prof. Garima Jain'
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
          subjectKey: 'AI-302',
          day: 1,
          startTime: '10:30',
          endTime: '12:30',
          room: 'Lab-VVNCC(Z-1)',
          type: LectureType.lab);
      await addSchedule(
          subjectKey: 'AI-303',
          day: 1,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No 104',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-305',
          day: 1,
          startTime: '14:30',
          endTime: '15:30',
          room: 'Room No 105',
          type: LectureType.lecture,
          facultyOverride: 'Prof. Jyothi Sonkar');
      await addSchedule(
          subjectKey: 'MAB-301',
          day: 1,
          startTime: '15:30',
          endTime: '16:30',
          room: 'Room No 105',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-307',
          day: 1,
          startTime: '16:30',
          endTime: '17:30',
          room: 'Room No 105',
          type: LectureType.internship,
          facultyOverride: 'Prof. Jyothi Sonkar');

      // TUESDAY (Day 2)
      await addSchedule(
          subjectKey: 'AI-304',
          day: 2,
          startTime: '10:30',
          endTime: '12:30',
          room: 'Lab-CSE',
          type: LectureType.lab);
      await addSchedule(
          subjectKey: 'AI-303',
          day: 2,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-307',
          day: 2,
          startTime: '14:30',
          endTime: '15:30',
          room: 'Room No 209',
          type: LectureType.internship,
          facultyOverride: 'Prof. Ankur Mishra');
      await addSchedule(
          subjectKey: 'AI-305',
          day: 2,
          startTime: '15:30',
          endTime: '16:30',
          room: 'Room No 209',
          type: LectureType.lecture,
          facultyOverride: 'Prof. Jyothi Sonkar');
      await addSchedule(
          subjectKey: 'AI-307',
          day: 2,
          startTime: '16:30',
          endTime: '17:30',
          room: 'Room No 209',
          type: LectureType.internship,
          facultyOverride: 'Prof. Garima Jain');

      // WEDNESDAY (Day 3)
      await addSchedule(
          subjectKey: 'MAB-301',
          day: 3,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-302',
          day: 3,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-304',
          day: 3,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-307',
          day: 3,
          startTime: '14:30',
          endTime: '15:30',
          room: 'Room No 209',
          type: LectureType.internship,
          facultyOverride: 'Prof. Jyothi Sonkar');
      await addSchedule(
          subjectKey: 'AI-306',
          day: 3,
          startTime: '15:30',
          endTime: '17:30',
          room: 'Lab-CSE',
          type: LectureType.lab);

      // THURSDAY (Day 4)
      await addSchedule(
          subjectKey: 'AI-304',
          day: 4,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-303',
          day: 4,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-303',
          day: 4,
          startTime: '12:30',
          endTime: '13:30',
          room: 'Room No 216',
          type: LectureType.lab);
      await addSchedule(
          subjectKey: 'AI-303',
          day: 4,
          startTime: '14:30',
          endTime: '15:30',
          room: 'VVNCC ZONE-2',
          type: LectureType.lab);
      await addSchedule(
          subjectKey: 'AI-302',
          day: 4,
          startTime: '15:30',
          endTime: '16:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'MAB-301',
          day: 4,
          startTime: '16:30',
          endTime: '17:30',
          room: 'Room No 209',
          type: LectureType.lecture);

      // FRIDAY (Day 5)
      await addSchedule(
          subjectKey: 'MAB-301',
          day: 5,
          startTime: '10:30',
          endTime: '11:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-302',
          day: 5,
          startTime: '11:30',
          endTime: '12:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-306',
          day: 5,
          startTime: '12:30',
          endTime: '13:30',
          room: 'CSE Lab',
          type: LectureType.lab);
      await addSchedule(
          subjectKey: 'AI-306',
          day: 5,
          startTime: '14:30',
          endTime: '15:30',
          room: 'CSE Lab',
          type: LectureType.lab);
      await addSchedule(
          subjectKey: 'AI-304',
          day: 5,
          startTime: '15:30',
          endTime: '16:30',
          room: 'Room No 209',
          type: LectureType.lecture);
      await addSchedule(
          subjectKey: 'AI-305',
          day: 5,
          startTime: '16:30',
          endTime: '17:30',
          room: 'Room No 209',
          type: LectureType.lecture,
          facultyOverride: 'Prof. Jyothi Sonkar');
    });

    await prefs.setString(PreferencesService.keySemesterStart, '2026-07-13');
  }
}
