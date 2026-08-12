import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:attendify/database/isar_service.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/database/collections/attendance_collection.dart';
import 'package:attendify/database/collections/schedule_collection.dart';
import 'package:attendify/database/collections/academic_task_collection.dart';
import 'package:attendify/database/collections/profile_collection.dart';
import 'package:attendify/database/collections/semester_collection.dart';
import 'package:attendify/services/preferences_service.dart';

final firebaseSyncServiceProvider = Provider<FirebaseSyncService>((ref) {
  if (!kIsWeb && Platform.isWindows) {
    return FirebaseSyncService(null, null, IsarService.instance.isar);
  }
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
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final Isar? _isar;

  FirebaseSyncService(this._auth, this._firestore, this._isar);

  bool _isListening = false;

  void startListeningToLocalChanges() {
    final isar = _isar;
    if (_auth == null || _firestore == null || isar == null) return;
    if (_isListening) return; // Guard against duplicate listeners
    _isListening = true;
    // Debounce or listen to collection changes
    isar.subjects.watchLazy().listen((_) => backupData());
    isar.attendances.watchLazy().listen((_) => backupData());
    isar.schedules.watchLazy().listen((_) => backupData());
    isar.academicTasks.watchLazy().listen((_) => backupData());
  }

  /// Performs a full backup of the local Isar database to Firestore.
  ///
  /// This should be called automatically whenever local data changes.
  Future<void> backupData() async {
    final auth = _auth;
    final firestore = _firestore;
    final isar = _isar;
    if (auth == null || firestore == null || isar == null) return;
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final uid = user.uid;
      final backupRef = firestore
          .collection('users')
          .doc(uid)
          .collection('backups')
          .doc('latest');

      final profiles = await isar.profiles.where().findAll();
      final semesters = await isar.semesters.where().findAll();
      final subjects = await isar.subjects.where().findAll();
      final attendances = await isar.attendances.where().findAll();
      final schedules = await isar.schedules.where().findAll();
      final tasks = await isar.academicTasks.where().findAll();

      final backupData = {
        'lastSynced': FieldValue.serverTimestamp(),
        'profiles': profiles.map((p) => p.toMap()).toList(),
        'semesters': semesters.map((s) => s.toMap()).toList(),
        'subjects': subjects.map((s) => s.toMap()).toList(),
        'attendances': attendances.map((a) => a.toMap()).toList(),
        'schedules': schedules.map((s) => s.toMap()).toList(),
        'tasks': tasks.map((t) => t.toMap()).toList(),
      };

      await backupRef.set(backupData);
    } catch (e) {
      // Background backup failed, log it or handle it gracefully
      debugPrint('Backup failed: $e');
    }
  }

  /// Restores data from Firestore to the local Isar database.
  ///
  /// This should be called when a user logs in.
  Future<void> restoreData() async {
    final auth = _auth;
    final firestore = _firestore;
    final isar = _isar;
    if (auth == null || firestore == null || isar == null) return;
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final uid = user.uid;
      final backupRef = firestore
          .collection('users')
          .doc(uid)
          .collection('backups')
          .doc('latest');

      final snapshot = await backupRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final profilesData =
          List<Map<String, dynamic>>.from(data['profiles'] ?? []);
      final semestersData =
          List<Map<String, dynamic>>.from(data['semesters'] ?? []);
      final subjectsData =
          List<Map<String, dynamic>>.from(data['subjects'] ?? []);
      final attendancesData =
          List<Map<String, dynamic>>.from(data['attendances'] ?? []);
      final schedulesData =
          List<Map<String, dynamic>>.from(data['schedules'] ?? []);
      final tasksData = List<Map<String, dynamic>>.from(data['tasks'] ?? []);

      final profiles = profilesData.map((e) => Profile.fromMap(e)).toList();
      final semesters = semestersData.map((e) => Semester.fromMap(e)).toList();
      final subjects = subjectsData.map((e) => Subject.fromMap(e)).toList();
      final attendances =
          attendancesData.map((e) => Attendance.fromMap(e)).toList();
      final schedules = schedulesData.map((e) => Schedule.fromMap(e)).toList();
      final tasks = tasksData.map((e) => AcademicTask.fromMap(e)).toList();

      await isar.writeTxn(() async {
        await isar.clear(); // Clear existing data before restoring

        // Handle legacy backups that might not have profiles/semesters
        if (profiles.isEmpty) {
          profiles.add(Profile()
            ..name = 'Restored Profile'
            ..isDefault = true);
        }
        await isar.profiles.putAll(profiles);

        final defaultProfileId = profiles.first.id;

        if (semesters.isEmpty) {
          semesters.add(Semester()
                ..profileId = defaultProfileId
                ..name = 'Restored Semester'
                ..startDate = DateTime(2000, 1,
                    1) // Safe old date to ensure all past attendance counts
              );
        }
        await isar.semesters.putAll(semesters);

        final activeSemesterId = semesters.first.id;

        // Just use PreferencesService.instance.setInt
        // If they were legacy, their subject's semesterId might point to a non-existent semester.
        // So we force them all to the active semester if it was a legacy restore (semesters was initially empty, so we only have 1).
        if (semesters.length == 1) {
          for (var s in subjects) {
            s.semesterId = activeSemesterId;
          }
          for (var a in attendances) {
            a.semesterId = activeSemesterId;
          }
          for (var s in schedules) {
            s.semesterId = activeSemesterId;
          }
          for (var t in tasks) {
            t.semesterId = activeSemesterId;
          }
        }

        await isar.subjects.putAll(subjects);
        await isar.attendances.putAll(attendances);
        await isar.schedules.putAll(schedules);
        await isar.academicTasks.putAll(tasks);
      });

      // Update preferences after transaction
      final prefs = PreferencesService.instance;
      if (profiles.isNotEmpty) {
        await prefs.setInt('active_profile_id', profiles.first.id);
      }
      if (semesters.isNotEmpty) {
        await prefs.setInt('active_semester_id', semesters.first.id);
      }
    } catch (e) {
      debugPrint('Restore failed: $e');
    }
  }
}
