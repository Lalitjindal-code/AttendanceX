import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:attendancex/database/isar_service.dart';
import 'package:attendancex/database/collections/subject_collection.dart';
import 'package:attendancex/database/collections/attendance_collection.dart';
import 'package:attendancex/database/collections/schedule_collection.dart';
import 'package:attendancex/database/collections/academic_task_collection.dart';

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  return FirebaseSyncService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    IsarService.instance.isar,
  );
});

final firebaseSyncOrchestratorProvider = Provider<void>((ref) {
  final service = ref.watch(firebaseSyncServiceProvider);
  service.startListeningToLocalChanges();
});

class FirebaseSyncService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Isar _isar;

  FirebaseSyncService(this._auth, this._firestore, this._isar);

  void startListeningToLocalChanges() {
    // Debounce or listen to collection changes
    _isar.subjects.watchLazy().listen((_) => backupData());
    _isar.attendances.watchLazy().listen((_) => backupData());
    _isar.schedules.watchLazy().listen((_) => backupData());
    _isar.academicTasks.watchLazy().listen((_) => backupData());
  }

  /// Performs a full backup of the local Isar database to Firestore.
  /// 
  /// This should be called automatically whenever local data changes.
  Future<void> backupData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final uid = user.uid;
      final backupRef = _firestore.collection('users').doc(uid).collection('backups').doc('latest');

      // Fetch all local data
      final subjects = await _isar.subjects.where().findAll();
      final attendances = await _isar.attendances.where().findAll();
      final schedules = await _isar.schedules.where().findAll();
      final tasks = await _isar.academicTasks.where().findAll();

      final backupData = {
        'lastSynced': FieldValue.serverTimestamp(),
        'subjects': subjects.map((s) => s.toMap()).toList(),
        'attendances': attendances.map((a) => a.toMap()).toList(),
        'schedules': schedules.map((s) => s.toMap()).toList(),
        'tasks': tasks.map((t) => t.toMap()).toList(),
      };

      await backupRef.set(backupData);
    } catch (e) {
      // Background backup failed, log it or handle it gracefully
      print('Backup failed: $e');
    }
  }

  /// Restores data from Firestore to the local Isar database.
  /// 
  /// This should be called when a user logs in.
  Future<void> restoreData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final uid = user.uid;
      final backupRef = _firestore.collection('users').doc(uid).collection('backups').doc('latest');

      final snapshot = await backupRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final subjectsData = List<Map<String, dynamic>>.from(data['subjects'] ?? []);
      final attendancesData = List<Map<String, dynamic>>.from(data['attendances'] ?? []);
      final schedulesData = List<Map<String, dynamic>>.from(data['schedules'] ?? []);
      final tasksData = List<Map<String, dynamic>>.from(data['tasks'] ?? []);

      final subjects = subjectsData.map((e) => Subject.fromMap(e)).toList();
      final attendances = attendancesData.map((e) => Attendance.fromMap(e)).toList();
      final schedules = schedulesData.map((e) => Schedule.fromMap(e)).toList();
      final tasks = tasksData.map((e) => AcademicTask.fromMap(e)).toList();

      await _isar.writeTxn(() async {
        await _isar.clear(); // Clear existing data before restoring
        await _isar.subjects.putAll(subjects);
        await _isar.attendances.putAll(attendances);
        await _isar.schedules.putAll(schedules);
        await _isar.academicTasks.putAll(tasks);
      });
    } catch (e) {
      print('Restore failed: $e');
    }
  }
}
