import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../database/database_providers.dart';
import '../../../database/repositories/attendance_repository.dart';

part 'attendance_providers.g.dart';

@Riverpod(keepAlive: true)
AttendanceRepository attendanceRepository(AttendanceRepositoryRef ref) {
  final isar = ref.watch(isarProvider);
  return AttendanceRepository(isar);
}
