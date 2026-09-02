import 'package:attendify/features/settings/models/app_settings.dart';
import 'package:attendify/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_strings.dart';
import '../../../navigation/app_routes.dart';
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
import '../../../services/widget_service.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../attendance/providers/attendance_providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../tutorials/providers/tutorial_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '...';
  final GlobalKey _communityKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasShown = ref.read(settingsTutorialNotifierProvider);
      if (!hasShown) {
        ShowCaseWidget.of(context).startShowCase([_communityKey]);
        ref.read(settingsTutorialNotifierProvider.notifier).markShown();
      }
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = 'v${info.version} (Build ${info.buildNumber})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final semester = ref.watch(semesterStateProvider);
    final semesterNotifier = ref.read(semesterStateProvider.notifier);
    final isCollegeUser = ref.watch(isCollegeUserProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppStrings.settingsTitle,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
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
          _buildAcademicProfileSection(
              context, ref, semester, semesterNotifier),
          const SizedBox(height: 24),
          _buildAttendanceRulesSection(context, ref, settings, notifier),
          const SizedBox(height: 24),
          _buildNotificationsSection(context, settings, notifier),
          const SizedBox(height: 24),
          _buildStorageBackupSection(context, ref, settings, notifier),
          const SizedBox(height: 24),
          _buildAboutSection(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHigh,
              Theme.of(context).colorScheme.surfaceContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          children: children,
        ),
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

  Widget _buildAppearanceSection(
      BuildContext context, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Appearance'),
        _buildSettingCard(
          children: [
            ListTile(
              leading:
                  _buildIcon(Icons.palette_rounded, const Color(0xFFAB47BC)),
              title: const Text('Theme'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select application theme',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment(
                            value: ThemeMode.system, label: Text('Sys')),
                        ButtonSegment(
                            value: ThemeMode.dark, label: Text('Dark')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (set) =>
                          notifier.updateThemeMode(set.first),
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        selectedBackgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
                        selectedForegroundColor:
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.dark_mode_rounded, const Color(0xFF42A5F5)),
              title: const Text(
                'AMOLED Dark Mode',
              ),
              subtitle: Text(
                'Use true black backgrounds',
              ),
              trailing: Switch(
                value: settings.isAmoled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                activeThumbColor: Theme.of(context).colorScheme.onPrimary,
                inactiveTrackColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
                inactiveThumbColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
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
        _buildSectionHeader(context, 'College Zone'),
        _buildSettingCard(
          children: [
            ListTile(
              leading:
                  _buildIcon(Icons.school_rounded, const Color(0xFF7E73FF)),
              title: const Text(
                'Change Semester & Branch',
              ),
              subtitle: Text(
                'Update your SATI Engineering details',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () {
                context.push(AppRoutes.collegeZone);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicProfileSection(
      BuildContext context, WidgetRef ref, var semester, var semesterNotifier) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Academic Profile'),
        _buildSettingCard(
          children: [
            ListTile(
              leading:
                  _buildIcon(Icons.edit_note_rounded, const Color(0xFF7E73FF)),
              title: const Text(
                'Semester Name',
              ),
              subtitle: Text(
                semester?.name ?? 'Not set',
              ),
              trailing: Icon(Icons.edit_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  size: 20),
              onTap: () {
                _showEditSemesterNameDialog(
                    context, semester?.name ?? '', semesterNotifier);
              },
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.date_range_rounded, const Color(0xFF26A69A)),
              title: const Text(
                'Semester Start Date',
              ),
              subtitle: Text(
                (semester != null && semester.startDate != null)
                    ? dateFormat.format(semester.startDate!)
                    : 'Not set',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: semester?.startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFF7E73FF),
                            surface: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) {
                  if (semester?.endDate != null &&
                      date.isAfter(semester!.endDate!)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Start date must be before end date.')));
                    }
                    return;
                  }
                  semesterNotifier.updateSemesterDates(date, semester?.endDate);
                }
              },
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading: _buildIcon(
                  Icons.event_available_rounded, const Color(0xFFEF5350)),
              title: const Text(
                'Semester End Date',
              ),
              subtitle: Text(
                (semester != null && semester.endDate != null)
                    ? dateFormat.format(semester.endDate!)
                    : 'Not set',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: semester?.endDate ??
                      semester?.startDate ??
                      DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: const Color(0xFF7E73FF),
                            surface: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                          ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) {
                  if (semester?.startDate != null &&
                      date.isBefore(semester!.startDate!)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('End date must be after start date.')));
                    }
                    return;
                  }
                  semesterNotifier.updateSemesterDates(
                      semester?.startDate ?? DateTime.now(), date);
                }
              },
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.layers_rounded, const Color(0xFFAB47BC)),
              title: const Text(
                'Manage Semesters',
              ),
              subtitle: Text(
                semester != null
                    ? 'Current: ${semester.name}'
                    : 'No active semester',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
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
        });
  }

  void _showIncludedSubjectsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (context) {
          return _IncludedSubjectsDialog(ref: ref);
        });
  }

  Widget _buildAttendanceRulesSection(BuildContext context, WidgetRef ref,
      AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Attendance Rules'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(
                  Icons.track_changes_rounded, const Color(0xFFFFA726)),
              title: const Text(
                'Goal Percentage',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${settings.defaultGoalPercentage.toInt()}%',
                  ),
                  Slider(
                    value: settings.defaultGoalPercentage,
                    min: 10.0,
                    max: 100.0,
                    divisions: 18,
                    thumbColor: Theme.of(context).colorScheme.onPrimary,
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                    onChanged: (val) => notifier.updateDefaultGoal(val),
                  ),
                ],
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading: _buildIcon(
                  Icons.local_hospital_rounded, const Color(0xFFEC407A)),
              title: const Text(
                'Medical Leave (ML)',
              ),
              subtitle: Text(
                'Counts as Present',
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading: _buildIcon(
                  Icons.work_history_rounded, const Color(0xFF5C6BC0)),
              title: const Text(
                'Duty Leave (GT)',
              ),
              subtitle: Text(
                'Excluded from calculation',
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading: _buildIcon(
                  Icons.checklist_rtl_rounded, const Color(0xFF4DB6AC)),
              title: const Text(
                'Included in Overall %',
              ),
              subtitle: Text(
                'Select which subjects affect overall attendance',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () {
                _showIncludedSubjectsDialog(context, ref);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
      BuildContext context, AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Notifications'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(
                  Icons.notifications_active_rounded, const Color(0xFF42A5F5)),
              title: const Text(
                'Enable Notifications',
              ),
              subtitle: Text(
                'Master switch for all alerts',
              ),
              trailing: Switch(
                value: settings.notificationsEnabled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                activeThumbColor: Theme.of(context).colorScheme.onPrimary,
                inactiveTrackColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
                inactiveThumbColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: (val) async {
                  if (val) {
                    final granted =
                        await NotificationService.instance.requestPermissions();
                    if (granted != true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Notification permissions denied. Please enable them in OS settings.')),
                      );
                    }
                  }
                  notifier.updateNotificationsEnabled(val);
                },
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.school_rounded, const Color(0xFFFFA726)),
              title: const Text(
                'Lecture Reminder',
              ),
              subtitle: Text(
                'Alert before class starts',
              ),
              enabled: settings.notificationsEnabled,
              trailing: DropdownButton<int>(
                value: [5, 10, 15, 30].contains(settings.lectureReminderMinutes)
                    ? settings.lectureReminderMinutes
                    : 10,
                dropdownColor:
                    Theme.of(context).colorScheme.surfaceContainerHigh,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                underline: const SizedBox(),
                icon: Icon(Icons.expand_more_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5)),
                items: [5, 10, 15, 30].map((mins) {
                  return DropdownMenuItem(
                      value: mins, child: Text('$mins mins'));
                }).toList(),
                onChanged: settings.notificationsEnabled
                    ? (val) {
                        if (val != null)
                          notifier.updateLectureReminderMinutes(val);
                      }
                    : null,
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading: _buildIcon(Icons.alarm_rounded, const Color(0xFFAB47BC)),
              title: const Text(
                'Daily Missed Reminders',
              ),
              subtitle: Text(
                'Alert if attendance is pending',
              ),
              trailing: Switch(
                value: settings.dailyReminderEnabled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                activeThumbColor: Theme.of(context).colorScheme.onPrimary,
                inactiveTrackColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
                inactiveThumbColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: settings.notificationsEnabled
                    ? (val) => notifier.updateDailyReminderEnabled(val)
                    : null,
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading: _buildIcon(
                  Icons.monitor_heart_rounded, const Color(0xFF26A69A)),
              title: const Text(
                'Notification Manager',
              ),
              subtitle: Text(
                'Manage notification preferences and filters',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () {
                // Manager screen nav
                context.push(AppRoutes.notificationManager);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStorageBackupSection(BuildContext context, WidgetRef ref,
      AppSettings settings, Settings notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Storage & Backup'),
        _buildSettingCard(
          children: [
            ListTile(
              leading:
                  _buildIcon(Icons.cloud_done_rounded, const Color(0xFF26A69A)),
              title: const Text(
                'Auto-Sync Status',
              ),
              subtitle: Text(
                'Data securely synced to Google account',
              ),
              trailing: TextButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Syncing data to cloud...')));
                  await ref.read(firebaseSyncServiceProvider).backupData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cloud sync complete!')));
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF7E73FF).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF7E73FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Sync Now',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.cloud_download_rounded, const Color(0xFF42A5F5)),
              title: const Text(
                'Restore from Cloud',
              ),
              subtitle: Text(
                'Fetch old data from Firebase',
              ),
              trailing: TextButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Restoring data from cloud...')));
                  await ref.read(firebaseSyncServiceProvider).restoreData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restore complete!')));
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF42A5F5).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF42A5F5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Restore',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.backup_rounded, const Color(0xFFFFA726)),
              title: const Text(
                'Local Backup & Restore',
              ),
              subtitle: Text(
                'Export or import data locally (.atfy)',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
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
        _buildSectionHeader(context, 'About'),
        _buildSettingCard(
          children: [
            ListTile(
              leading: _buildIcon(
                  Icons.info_outline_rounded, const Color(0xFF42A5F5)),
              title: const Text(
                'App Version',
              ),
              subtitle: Text(
                _appVersion,
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            Showcase(
              key: _communityKey,
              description: 'Join our WhatsApp Community to get updates, report bugs, and give feedback!',
              child: ListTile(
                leading:
                    _buildIcon(Icons.groups_rounded, const Color(0xFF4CAF50)),
                title: const Text(
                  'Join the community',
                ),
                subtitle: const Text(
                  'For feedback and review',
                ),
                trailing: Icon(Icons.open_in_new_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)),
                onTap: () async {
                  final url = Uri.parse('https://chat.whatsapp.com/JuejidlVtPpFTv4E1P4SF7');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open link')));
                    }
                  }
                },
              ),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.feedback_outlined, const Color(0xFFFFA726)),
              title: const Text(
                'Feedback',
              ),
              subtitle: Text(
                'Send us your thoughts',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () => context.push(AppRoutes.feedback),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.support_agent_rounded, const Color(0xFF26A69A)),
              title: const Text(
                'My Requests & Support',
              ),
              subtitle: const Text(
                'View and chat on your tickets',
              ),
              trailing: Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () => context.push(AppRoutes.userSupport),
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.privacy_tip_outlined, const Color(0xFF9575CD)),
              title: const Text(
                'Privacy Policy',
              ),
              subtitle: Text(
                'How we handle your data',
              ),
              trailing: Icon(Icons.open_in_new_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3)),
              onTap: () async {
                final url = Uri.parse('https://www.freeprivacypolicy.com/live/f06cdb75-10eb-4043-a6cd-567f13db79c2');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            Divider(
                color: Theme.of(context).colorScheme.outlineVariant, height: 1),
            ListTile(
              leading:
                  _buildIcon(Icons.favorite_rounded, const Color(0xFFFF6B8A)),
              title: const Text(
                'Developed by',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF7E73FF), Color(0xFFFF6B8A)],
                    ).createShader(bounds),
                    child: const Text(
                      'Lalit Jindal',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://www.linkedin.com/in/lalitjindal-ai/'), mode: LaunchMode.externalApplication),
                        child: const FaIcon(FontAwesomeIcons.linkedin, size: 22, color: Color(0xFF0A66C2)),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://github.com/Lalitjindal-code'), mode: LaunchMode.externalApplication),
                        child: const FaIcon(FontAwesomeIcons.github, size: 22, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () => launchUrl(Uri.parse('https://www.instagram.com/lalitjindal__/'), mode: LaunchMode.externalApplication),
                        child: const FaIcon(FontAwesomeIcons.instagram, size: 22, color: Color(0xFFE1306C)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditSemesterNameDialog(
      BuildContext context, String currentName, var semesterNotifier) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          title: Text('Edit Semester Name',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Semester Name',
              labelStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant)),
              focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7))),
            ),
            FilledButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  semesterNotifier.updateSemesterName(newName);
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary),
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
  State<_SemesterManagementDialog> createState() =>
      _SemesterManagementDialogState();
}

class _SemesterManagementDialogState extends State<_SemesterManagementDialog> {
  List<dynamic> _semesters = [];
  bool _isLoading = true;

  int _activeSemesterId = 1;

  @override
  void initState() {
    super.initState();
    _activeSemesterId = PreferencesService.instance
        .getInt('active_semester_id', defaultValue: 1);
    _loadSemesters();
  }

  Future<void> _loadSemesters() async {
    final repo = widget.ref.read(semesterRepositoryProvider);
    final activeProfileId = PreferencesService.instance
        .getInt('active_profile_id', defaultValue: 1);
    final sems = await repo.getSemestersByProfile(activeProfileId);
    setState(() {
      _semesters = sems;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AlertDialog(
          content: SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator())));
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

                  final activeProfileId = PreferencesService.instance
                      .getInt('active_profile_id', defaultValue: 1);
                  final newSemId = await repo.upsertSemester(Semester()
                    ..profileId = activeProfileId
                    ..name = 'Semester ${_semesters.length + 1}'
                    ..startDate = DateTime.now());

                  // Set active via notifier to update global app state
                  await widget.ref
                      .read(semesterStateProvider.notifier)
                      .setActiveSemester(newSemId);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
              );
            }
            final sem = _semesters[index];
            final isCurrent = sem.id == _activeSemesterId;
            return RadioListTile<int>(
              title: Text(sem.name),
              value: sem.id,
              groupValue: _activeSemesterId,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (int? value) async {
                if (value != null && value != _activeSemesterId) {
                  setState(() {
                    _activeSemesterId = value;
                  });
                  await widget.ref
                      .read(semesterStateProvider.notifier)
                      .setActiveSemester(value);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              secondary: _semesters.length <= 1
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                                  title: const Text('Delete Semester?'),
                                  content: const Text(
                                      'This will delete all subjects, schedules, and attendance records associated with this semester. This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: const Text('Cancel')),
                                    FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Delete')),
                                  ],
                                ));

                        if (confirm == true) {
                          final repo =
                              widget.ref.read(semesterRepositoryProvider);
                          await repo.deleteSemester(sem.id);
                          if (isCurrent) {
                            final activeProfileId = PreferencesService.instance
                                .getInt('active_profile_id', defaultValue: 1);
                            final rem = await repo
                                .getSemestersByProfile(activeProfileId);
                            if (rem.isNotEmpty) {
                              await widget.ref
                                  .read(semesterStateProvider.notifier)
                                  .setActiveSemester(rem.first.id);
                            }
                          } else {
                            final currentId = PreferencesService.instance
                                .getInt('active_semester_id', defaultValue: 1);
                            await widget.ref
                                .read(semesterStateProvider.notifier)
                                .setActiveSemester(currentId);
                          }
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      },
                    ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Close'))
      ],
    );
  }
}

class _IncludedSubjectsDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _IncludedSubjectsDialog({required this.ref});

  @override
  ConsumerState<_IncludedSubjectsDialog> createState() =>
      _IncludedSubjectsDialogState();
}

class _IncludedSubjectsDialogState
    extends ConsumerState<_IncludedSubjectsDialog> {
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
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) async {
                          subject.isIncludedInOverall = val;
                          setState(() {});
                          final repo =
                              widget.ref.read(subjectRepositoryProvider);
                          await repo.update(subject);
                          // Trigger dashboard rebuild by updating a dummy pref or reloading
                          widget.ref
                              .read(settingsProvider.notifier)
                              .updateDefaultGoal(widget.ref
                                  .read(settingsProvider)
                                  .defaultGoalPercentage);
                          WidgetService.instance.updateWidget();
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Done'))
      ],
    );
  }
}
