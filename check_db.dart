import 'dart:io';
import 'package:isar/isar.dart';
import 'lib/database/collections/semester_collection.dart';
import 'lib/database/collections/subject_collection.dart';
import 'lib/database/collections/attendance_collection.dart';

void main() async {
  await Isar.initializeIsarCore(download: true);
  final isar = await Isar.open(
    [SemesterSchema, SubjectSchema, AttendanceSchema],
    directory: Directory.current.path,
  );
  
  final semCount = await isar.semesters.count();
  final subCount = await isar.subjects.count();
  final attCount = await isar.attendances.count();
  
  print('Semesters: $semCount');
  print('Subjects: $subCount');
  print('Attendances: $attCount');
  
  await isar.close();
}
