import 'package:attendancex/core/enums/gt_mode.dart';
import 'package:attendancex/features/settings/models/app_settings.dart';
import 'package:attendancex/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../scripts/import_timetable.dart';
import '../providers/settings_provider.dart';
import '../../../database/database_providers.dart';
import '../../../database/collections/attendance_collection.dart';
import 'package:isar/isar.dart';
import '../../backup/screens/backup_restore_screen.dart' as attendancex_backup_screen;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        children: [
          _buildAppearanceSection(context, settings, notifier, theme),
          const Divider(),
          _buildAcademicProfileSection(context, settings, notifier, theme),
          const Divider(),
          _buildAttendanceRulesSection(context, settings, notifier, theme),
          const Divider(),
          _buildNotificationsSection(context, settings, notifier, theme),
          const Divider(),
          _buildStorageBackupSection(context, settings, notifier, theme),
          const Divider(),
          _buildAdvancedSection(context, ref, settings, notifier, theme),
          const Divider(),
          _buildAboutSection(context, theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Appearance', theme),
        ListTile(
          title: const Text('Theme'),
          subtitle: const Text('Select application theme'),
          trailing: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (set) => notifier.updateThemeMode(set.first),
          ),
        ),
        SwitchListTile(
          title: const Text('AMOLED Dark Mode'),
          subtitle: const Text('Use true black backgrounds'),
          value: settings.isAmoled,
          onChanged: settings.themeMode != ThemeMode.light
              ? (val) => notifier.updateIsAmoled(val)
              : null, // Disabled in light mode
        ),
      ],
    );
  }

  Widget _buildAcademicProfileSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Academic Profile', theme),
        ListTile(
          title: const Text('Semester Start Date'),
          subtitle: Text(settings.semesterStartDate != null ? dateFormat.format(settings.semesterStartDate!) : 'Not set'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: settings.semesterStartDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              if (settings.semesterEndDate != null && date.isAfter(settings.semesterEndDate!)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start date must be before end date.')));
                }
                return;
              }
              notifier.updateSemesterDates(date, settings.semesterEndDate);
            }
          },
        ),
        ListTile(
          title: const Text('Semester End Date'),
          subtitle: Text(settings.semesterEndDate != null ? dateFormat.format(settings.semesterEndDate!) : 'Not set'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: settings.semesterEndDate ?? settings.semesterStartDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              if (settings.semesterStartDate != null && date.isBefore(settings.semesterStartDate!)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End date must be after start date.')));
                }
                return;
              }
              notifier.updateSemesterDates(settings.semesterStartDate, date);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceRulesSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Attendance Rules', theme),
        ListTile(
          title: const Text('Goal Percentage'),
          subtitle: Text('${settings.defaultGoalPercentage.toInt()}%'),
          trailing: SizedBox(
            width: 200,
            child: Slider(
              value: settings.defaultGoalPercentage,
              min: 10.0,
              max: 100.0,
              divisions: 18, // Steps of 5
              label: '${settings.defaultGoalPercentage.toInt()}%',
              onChanged: (val) => notifier.updateDefaultGoal(val),
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Medical Leave (ML)'),
          subtitle: Text(settings.medicalCountsAsPresent ? 'Counts as Present' : 'Excluded from calculation'),
          value: settings.medicalCountsAsPresent,
          onChanged: (val) => notifier.updateMedicalPolicy(val),
        ),
        ListTile(
          title: const Text('Duty Leave (GT)'),
          subtitle: Text(settings.gtMode.description),
          trailing: DropdownButton<GtMode>(
            value: settings.gtMode,
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
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notifications', theme),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Master switch for all alerts'),
          value: settings.notificationsEnabled,
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
        ListTile(
          title: const Text('Lecture Reminder'),
          subtitle: const Text('Alert before class starts'),
          enabled: settings.notificationsEnabled,
          trailing: DropdownButton<int>(
            value: [5, 10, 15, 30].contains(settings.lectureReminderMinutes) ? settings.lectureReminderMinutes : 10,
            items: [5, 10, 15, 30].map((mins) {
              return DropdownMenuItem(value: mins, child: Text('$mins mins'));
            }).toList(),
            onChanged: settings.notificationsEnabled
                ? (val) {
                    if (val != null) notifier.updateLectureReminderMinutes(val);
                  }
                : null,
          ),
        ),
        ListTile(
          title: const Text('Task Reminder'),
          subtitle: const Text('Default alert for new tasks'),
          enabled: settings.notificationsEnabled,
          trailing: DropdownButton<int>(
            value: settings.defaultTaskReminderOffsets.isNotEmpty ? settings.defaultTaskReminderOffsets.first : 1440,
            items: const [
              DropdownMenuItem(value: 60, child: Text('1 hour before')),
              DropdownMenuItem(value: 180, child: Text('3 hours before')),
              DropdownMenuItem(value: 1440, child: Text('1 day before')),
              DropdownMenuItem(value: 2880, child: Text('2 days before')),
            ],
            onChanged: settings.notificationsEnabled
                ? (val) {
                    if (val != null) notifier.updateDefaultTaskReminderOffsets([val]);
                  }
                : null,
          ),
        ),
        SwitchListTile(
          title: const Text('Daily Missed Reminders'),
          subtitle: const Text('Alert if attendance is pending'),
          value: settings.dailyReminderEnabled,
          onChanged: settings.notificationsEnabled
              ? (val) => notifier.updateDailyReminderEnabled(val)
              : null,
        ),
        ListTile(
          title: const Text('Daily Reminder Time'),
          subtitle: Text(settings.dailyReminderTime),
          enabled: settings.notificationsEnabled && settings.dailyReminderEnabled,
          trailing: const Icon(Icons.access_time),
          onTap: settings.notificationsEnabled && settings.dailyReminderEnabled
              ? () async {
                  final timeParts = settings.dailyReminderTime.split(':');
                  final initialTime = TimeOfDay(
                    hour: int.tryParse(timeParts[0]) ?? 20,
                    minute: int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
                  );
                  final time = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                  );
                  if (time != null) {
                    final h = time.hour.toString().padLeft(2, '0');
                    final m = time.minute.toString().padLeft(2, '0');
                    notifier.updateDailyReminderTime('$h:$m');
                  }
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildStorageBackupSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Storage & Backup', theme),
        ListTile(
          title: const Text('Backup & Restore'),
          subtitle: const Text('Export or import your data'),
          leading: const Icon(Icons.cloud_upload_outlined),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const attendancex_backup_screen.BackupRestoreScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context, WidgetRef ref, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Advanced', theme),
        ListTile(
          title: const Text('Import Timetable'),
          subtitle: const Text('Load schedule from script'),
          leading: const Icon(Icons.download),
          onTap: () async {
            await ImportTimetable.run();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable Imported! Restart app if needed.')));
            }
          },
        ),
        ListTile(
          title: Text(
            'Clear Today\'s Attendance',
            style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Deletes all attendance marked today'),
          leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
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
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('About', theme),
        const ListTile(
          title: Text('App Version'),
          subtitle: Text('1.0.0 (Beta)'),
          leading: Icon(Icons.info_outline),
        ),
        const ListTile(
          title: Text('Feedback'),
          subtitle: Text('Coming Soon'),
          leading: Icon(Icons.feedback_outlined),
          enabled: false,
        ),
        const ListTile(
          title: Text('Privacy Policy'),
          subtitle: Text('Coming Soon'),
          leading: Icon(Icons.privacy_tip_outlined),
          enabled: false,
        ),
      ],
    );
  }
}
