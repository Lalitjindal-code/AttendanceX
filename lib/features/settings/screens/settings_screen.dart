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
          _buildAttendanceRulesSection(context, settings, notifier, theme),
          const Divider(),
          _buildAcademicTermSection(context, settings, notifier, theme),
          const Divider(),
          _buildNotificationsSection(context, settings, notifier, theme),
          const Divider(),
          ListTile(
            title: const Text('Import Timetable'),
            subtitle: const Text('Load schedule from script'),
            trailing: const Icon(Icons.download),
            onTap: () async {
              await ImportTimetable.run();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable Imported! Restart app if needed.')));
              }
            },
          ),
          ListTile(
            title: const Text('Clear Today\'s Attendance', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Deletes all attendance marked today'),
            trailing: const Icon(Icons.delete, color: Colors.red),
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Appearance', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        ),
        ListTile(
          title: const Text('Theme'),
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
      ],
    );
  }

  Widget _buildAttendanceRulesSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Attendance Rules', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        ),
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
        ListTile(
          title: const Text('Medical Leave (ML)'),
          subtitle: Text(settings.medicalCountsAsPresent ? 'Counts as Present' : 'Excluded from calculation'),
          trailing: Switch(
            value: settings.medicalCountsAsPresent,
            onChanged: (val) => notifier.updateMedicalPolicy(val),
          ),
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

  Widget _buildAcademicTermSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Academic Term', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        ),
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

  Widget _buildNotificationsSection(BuildContext context, AppSettings settings, Settings notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Notifications', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
        ),
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
          title: const Text('Lecture Reminder Offset'),
          subtitle: const Text('Minutes before class starts'),
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
        SwitchListTile(
          title: const Text('Daily Missed Reminders'),
          subtitle: const Text('Reminds you if attendance is pending'),
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
}
