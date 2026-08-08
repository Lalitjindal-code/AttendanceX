import 'package:attendify/core/enums/gt_mode.dart';
import 'package:attendify/features/settings/models/app_settings.dart';
import 'package:attendify/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../navigation/app_routes.dart';
import '../../../scripts/import_timetable.dart';
import '../providers/settings_provider.dart';
import '../../../database/database_providers.dart';
import '../../../database/collections/attendance_collection.dart';
import 'package:isar/isar.dart';
import '../../sync/services/firebase_sync_service.dart';
import '../../backup/screens/backup_restore_screen.dart';
import '../providers/semester_provider.dart';
import '../../../database/collections/semester_collection.dart';
import '../../../database/repositories/semester_repository.dart';
import '../../../services/preferences_service.dart';
import '../../college/providers/college_auth_provider.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../database/repositories/subject_repository.dart';
import '../../../services/widget_service.dart';
import '../../subjects/providers/subject_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final semester = ref.watch(semesterStateProvider);
    final semesterNotifier = ref.read(semesterStateProvider.notifier);
    final isCollegeUser = ref.watch(isCollegeUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B13),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(AppStrings.settingsTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildAppearanceSection(context, settings, notifier),
          const SizedBox(height: 24),
          if (isCollegeUser) ...[
            _buildCollegeSection(context),
            const SizedBox(height: 24),
          ],
          _buildAcademicProfileSection(context, ref, semester, semesterNotifier),
          const SizedBox(height: 24),
          _buildAttendanceRulesSection(context, ref, settings, notifier),
          const SizedBox(height: 24),
          _buildNotificationsSection(context, settings, notifier),
          const SizedBox(height: 24),
          _buildSecuritySection(context, settings, notifier),
          const SizedBox(height: 24),
          _buildStorageBackupSection(context, ref, settings, notifier),
          const SizedBox(height: 24),
          _buildAboutSection(context),
          const SizedBox(height: 32),
          _buildDangerZoneSection(context, ref),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7E73FF),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16162C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Appearance'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.palette_rounded, const Color(0xFFAB47BC)),
              title: const Text('Theme', style: TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select application theme', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment(value: ThemeMode.system, label: Text('Sys')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (set) => notifier.updateThemeMode(set.first),
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        selectedBackgroundColor: const Color(0xFF7E73FF).withValues(alpha: 0.3),
                        foregroundColor: Colors.white,
                        selectedForegroundColor: const Color(0xFF7E73FF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.dark_mode_rounded, const Color(0xFF42A5F5)),
              title: const Text('AMOLED Dark Mode', style: TextStyle(color: Colors.white)),
              subtitle: Text('Use true black backgrounds', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Switch(
                value: settings.isAmoled,
                activeTrackColor: const Color(0xFF7E73FF),
                activeThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: settings.themeMode != ThemeMode.light
                    ? (val) => notifier.updateIsAmoled(val)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollegeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('College Zone'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.school_rounded, const Color(0xFF7E73FF)),
              title: const Text('Change Semester & Branch', style: TextStyle(color: Colors.white)),
              subtitle: Text('Update your SATI Engineering details', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () {
                context.push(AppRoutes.collegeZone);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicProfileSection(BuildContext context, WidgetRef ref, var semester, var semesterNotifier) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Academic Profile'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.edit_note_rounded, const Color(0xFF7E73FF)),
              title: const Text('Semester Name', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                semester?.name ?? 'Not set',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6))
              ),
              trailing: Icon(Icons.edit_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
              onTap: () {
                _showEditSemesterNameDialog(context, semester?.name ?? '', semesterNotifier);
              },
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.date_range_rounded, const Color(0xFF26A69A)),
              title: const Text('Semester Start Date', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                (semester != null && semester.startDate != null) ? dateFormat.format(semester.startDate!) : 'Not set',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6))
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: semester?.startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF7E73FF),
                        surface: Color(0xFF16162C),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) {
                  if (semester?.endDate != null && date.isAfter(semester!.endDate!)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start date must be before end date.')));
                    }
                    return;
                  }
                  semesterNotifier.updateSemesterDates(date, semester?.endDate);
                }
              },
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.event_available_rounded, const Color(0xFFEF5350)),
              title: const Text('Semester End Date', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                (semester != null && semester.endDate != null) ? dateFormat.format(semester.endDate!) : 'Not set',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6))
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: semester?.endDate ?? semester?.startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF7E73FF),
                        surface: Color(0xFF16162C),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) {
                  if (semester?.startDate != null && date.isBefore(semester!.startDate!)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date must be after start date.')));
                    }
                    return;
                  }
                  semesterNotifier.updateSemesterDates(semester?.startDate ?? DateTime.now(), date);
                }
              },
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.layers_rounded, const Color(0xFFAB47BC)),
              title: const Text('Manage Semesters', style: TextStyle(color: Colors.white)),
              subtitle: Text(semester != null ? 'Current: ${semester.name}' : 'No active semester', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () {
                _showSemesterManagementDialog(context, ref);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showSemesterManagementDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return _SemesterManagementDialog(ref: ref);
      }
    );
  }

  void _showIncludedSubjectsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return _IncludedSubjectsDialog(ref: ref);
      }
    );
  }

  Widget _buildAttendanceRulesSection(BuildContext context, WidgetRef ref, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Attendance Rules'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.track_changes_rounded, const Color(0xFFFFA726)),
              title: const Text('Goal Percentage', style: TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${settings.defaultGoalPercentage.toInt()}%', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                  Slider(
                    value: settings.defaultGoalPercentage,
                    min: 10.0,
                    max: 100.0,
                    divisions: 18,
                    thumbColor: Colors.white,
                    activeColor: const Color(0xFF7E73FF),
                    inactiveColor: Colors.white.withValues(alpha: 0.1),
                    onChanged: (val) => notifier.updateDefaultGoal(val),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.local_hospital_rounded, const Color(0xFFEC407A)),
              title: const Text('Medical Leave (ML)', style: TextStyle(color: Colors.white)),
              subtitle: Text(settings.medicalCountsAsPresent ? 'Counts as Present' : 'Excluded from calculation', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Switch(
                value: settings.medicalCountsAsPresent,
                activeTrackColor: const Color(0xFF7E73FF),
                activeThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: (val) => notifier.updateMedicalPolicy(val),
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.work_history_rounded, const Color(0xFF5C6BC0)),
              title: const Text('Duty Leave (GT)', style: TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(settings.gtMode.description, style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                  DropdownButton<GtMode>(
                    isExpanded: true,
                    value: settings.gtMode,
                    dropdownColor: const Color(0xFF16162C),
                    style: const TextStyle(color: Colors.white),
                    underline: const SizedBox(),
                    icon: Icon(Icons.expand_more_rounded, color: Colors.white.withValues(alpha: 0.5)),
                    items: GtMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(mode.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) notifier.updateGtMode(val);
                    },
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.checklist_rtl_rounded, const Color(0xFF4DB6AC)),
              title: const Text('Included in Overall %', style: TextStyle(color: Colors.white)),
              subtitle: Text('Select which subjects affect overall attendance', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () {
                _showIncludedSubjectsDialog(context, ref);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notifications'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.notifications_active_rounded, const Color(0xFF42A5F5)),
              title: const Text('Enable Notifications', style: TextStyle(color: Colors.white)),
              subtitle: Text('Master switch for all alerts', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Switch(
                value: settings.notificationsEnabled,
                activeTrackColor: const Color(0xFF7E73FF),
                activeThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: (val) async {
                  if (val) {
                    final granted = await NotificationService.instance.requestPermissions();
                    if (granted != true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification permissions denied. Please enable them in OS settings.')),
                      );
                    }
                  }
                  notifier.updateNotificationsEnabled(val);
                },
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.school_rounded, const Color(0xFFFFA726)),
              title: const Text('Lecture Reminder', style: TextStyle(color: Colors.white)),
              subtitle: Text('Alert before class starts', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              enabled: settings.notificationsEnabled,
              trailing: DropdownButton<int>(
                value: [5, 10, 15, 30].contains(settings.lectureReminderMinutes) ? settings.lectureReminderMinutes : 10,
                dropdownColor: const Color(0xFF16162C),
                style: const TextStyle(color: Colors.white),
                underline: const SizedBox(),
                icon: Icon(Icons.expand_more_rounded, color: Colors.white.withValues(alpha: 0.5)),
                items: [5, 10, 15, 30].map((mins) {
                  return DropdownMenuItem(value: mins, child: Text('$mins mins'));
                }).toList(),
                onChanged: settings.notificationsEnabled ? (val) { if (val != null) notifier.updateLectureReminderMinutes(val); } : null,
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.alarm_rounded, const Color(0xFFAB47BC)),
              title: const Text('Daily Missed Reminders', style: TextStyle(color: Colors.white)),
              subtitle: Text('Alert if attendance is pending', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Switch(
                value: settings.dailyReminderEnabled,
                activeTrackColor: const Color(0xFF7E73FF),
                activeThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: settings.notificationsEnabled ? (val) => notifier.updateDailyReminderEnabled(val) : null,
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.monitor_heart_rounded, const Color(0xFF26A69A)),
              title: const Text('Manage & Test Notifications', style: TextStyle(color: Colors.white)),
              subtitle: Text('View scheduled and test reminders', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () {
                context.push(AppRoutes.notifications);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Security'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.fingerprint_rounded, const Color(0xFFAB47BC)),
              title: const Text('Biometric App Lock', style: TextStyle(color: Colors.white)),
              subtitle: Text('Require authentication to open app', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Switch(
                value: settings.isAppLockEnabled,
                activeTrackColor: const Color(0xFF7E73FF),
                activeThumbColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: (val) async {
                  if (val) {
                    // Try to authenticate before enabling
                    final localAuth = LocalAuthentication();
                    try {
                      final bool canCheck = await localAuth.canCheckBiometrics || await localAuth.isDeviceSupported();
                      if (!canCheck) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your device does not support biometric/PIN authentication.')));
                        }
                        return;
                      }
                      
                      final didAuth = await localAuth.authenticate(
                        localizedReason: 'Authenticate to enable App Lock',
                        persistAcrossBackgrounding: true,
                        biometricOnly: false,
                      );
                      
                      if (didAuth) {
                        notifier.updateIsAppLockEnabled(true);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication error: $e')));
                      }
                    }
                  } else {
                    notifier.updateIsAppLockEnabled(false);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorageBackupSection(BuildContext context, WidgetRef ref, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Storage & Backup'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.cloud_done_rounded, const Color(0xFF26A69A)),
              title: const Text('Auto-Sync Status', style: TextStyle(color: Colors.white)),
              subtitle: Text('Data securely synced to Google account', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: TextButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing data to cloud...')));
                  await ref.read(firebaseSyncServiceProvider).backupData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloud sync complete!')));
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF7E73FF).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF7E73FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Sync Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.backup_rounded, const Color(0xFFFFA726)),
              title: const Text('Local Backup & Restore', style: TextStyle(color: Colors.white)),
              subtitle: Text('Export or import data locally (.atfy)', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupRestoreScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(Icons.info_outline_rounded, const Color(0xFF42A5F5)),
              title: const Text('App Version', style: TextStyle(color: Colors.white)),
              subtitle: Text('1.0.0 (Beta)', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.feedback_outlined, const Color(0xFFFFA726)),
              title: const Text('Feedback', style: TextStyle(color: Colors.white)),
              subtitle: Text('Send us your thoughts', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.3)),
              onTap: () => context.push(AppRoutes.feedback),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
            ListTile(
              leading: _buildIcon(Icons.favorite_rounded, const Color(0xFFFF6B8A)),
              title: const Text('Developed by', style: TextStyle(color: Colors.white)),
              subtitle: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF7E73FF), Color(0xFFFF6B8A)],
                ).createShader(bounds),
                child: const Text(
                  'Lallit Jindal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'DANGER ZONE',
            style: TextStyle(
              color: const Color(0xFFFF5F5F).withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF5F5F).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF5F5F).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: _buildIcon(Icons.delete_outline_rounded, const Color(0xFFFF5F5F)),
                title: const Text('Clear Today\'s Attendance', style: TextStyle(color: Color(0xFFFF5F5F), fontWeight: FontWeight.bold)),
                subtitle: Text('Deletes all attendance marked today', style: TextStyle(color: const Color(0xFFFF5F5F).withValues(alpha: 0.6))),
                onTap: () async {
                  final isar = ref.read(isarProvider);
                  final now = DateTime.now();
                  final todayUtc = DateTime.utc(now.year, now.month, now.day);
                  await isar.writeTxn(() async {
                    await isar.attendances.filter().dateEqualTo(todayUtc).deleteAll();
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cleared today\'s attendance!')));
                  }
                },
              ),
              Divider(color: const Color(0xFFFF5F5F).withValues(alpha: 0.2), height: 1),
              ListTile(
                leading: _buildIcon(Icons.download_rounded, const Color(0xFFEF5350)),
                title: const Text('Import Timetable', style: TextStyle(color: Colors.white)),
                subtitle: Text('Warning: Overwrites existing schedule', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                onTap: () async {
                  await ImportTimetable.run();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable Imported! Restart app if needed.')));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditSemesterNameDialog(BuildContext context, String currentName, var semesterNotifier) {
    final controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16162C),
          title: const Text('Edit Semester Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Semester Name',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7E73FF))),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  semesterNotifier.updateSemesterName(newName);
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7E73FF)),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _SemesterManagementDialog extends StatefulWidget {
  final WidgetRef ref;
  const _SemesterManagementDialog({required this.ref});
  
  @override
  State<_SemesterManagementDialog> createState() => _SemesterManagementDialogState();
}

class _SemesterManagementDialogState extends State<_SemesterManagementDialog> {
  List<dynamic> _semesters = [];
  bool _isLoading = true;

  int _activeSemesterId = 1;

  @override
  void initState() {
    super.initState();
    _activeSemesterId = PreferencesService.instance.getInt('active_semester_id', defaultValue: 1);
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    final repo = widget.ref.read(semesterRepositoryProvider);
    final activeProfileId = PreferencesService.instance.getInt('active_profile_id', defaultValue: 1);
    final sems = await repo.getSemestersByProfile(activeProfileId);
    setState(() {
      _semesters = sems;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
    }
    
    return AlertDialog(
      title: const Text('Manage Semesters'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _semesters.length + 1,
          itemBuilder: (context, index) {
            if (index == _semesters.length) {
              return ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add New Semester'),
                onTap: () async {
                  final repo = widget.ref.read(semesterRepositoryProvider);
                  
                  final activeProfileId = PreferencesService.instance.getInt('active_profile_id', defaultValue: 1);
                  final newSemId = await repo.upsertSemester(Semester()
                    ..profileId = activeProfileId
                    ..name = 'Semester ${_semesters.length + 1}'
                    ..startDate = DateTime.now()
                  );
                  
                  // Set active via notifier to update global app state
                  await widget.ref.read(semesterStateProvider.notifier).setActiveSemester(newSemId);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
              );
            }
            final sem = _semesters[index];
            final isCurrent = sem.id == _activeSemesterId;
            return ListTile(
              title: Text(sem.name),
              trailing: isCurrent ? const Icon(Icons.check_circle, color: Color(0xFF7E73FF)) : null,
              onTap: () async {
                if (!isCurrent) {
                  await widget.ref.read(semesterStateProvider.notifier).setActiveSemester(sem.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              onLongPress: () async {
                if (_semesters.length <= 1) return;
                
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete Semester?'),
                    content: const Text('This will delete all subjects, schedules, and attendance records associated with this semester. This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(c, true), 
                        child: const Text('Delete')
                      ),
                    ],
                  )
                );
                
                if (confirm == true) {
                  final repo = widget.ref.read(semesterRepositoryProvider);
                  await repo.deleteSemester(sem.id);
                  if (isCurrent) {
                    final activeProfileId = PreferencesService.instance.getInt('active_profile_id', defaultValue: 1);
                    final rem = await repo.getSemestersByProfile(activeProfileId);
                    if (rem.isNotEmpty) {
                      await widget.ref.read(semesterStateProvider.notifier).setActiveSemester(rem.first.id);
                    }
                  } else {
                    final currentId = PreferencesService.instance.getInt('active_semester_id', defaultValue: 1);
                    await widget.ref.read(semesterStateProvider.notifier).setActiveSemester(currentId);
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
      ],
    );
  }
}

class _IncludedSubjectsDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _IncludedSubjectsDialog({required this.ref});

  @override
  ConsumerState<_IncludedSubjectsDialog> createState() => _IncludedSubjectsDialogState();
}

class _IncludedSubjectsDialogState extends ConsumerState<_IncludedSubjectsDialog> {
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final semester = widget.ref.read(semesterStateProvider);
    if (semester == null) return;
    
    final repo = widget.ref.read(subjectRepositoryProvider);
    final subjects = await repo.watchAll(semester.id).first;
    
    if (mounted) {
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Overall % Inclusion'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _subjects.isEmpty
                ? const Text('No subjects found.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      return SwitchListTile(
                        title: Text(subject.name),
                        value: subject.isIncludedInOverall,
                        activeColor: const Color(0xFF7E73FF),
                        onChanged: (val) async {
                          subject.isIncludedInOverall = val;
                          setState(() {});
                          final repo = widget.ref.read(subjectRepositoryProvider);
                          await repo.update(subject);
                          // Trigger dashboard rebuild by updating a dummy pref or reloading
                          widget.ref.read(settingsProvider.notifier).updateDefaultGoal(
                              widget.ref.read(settingsProvider).defaultGoalPercentage);
                          WidgetService.instance.updateWidget();
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))
      ],
    );
  }
}

