import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendify/features/settings/models/app_settings.dart';
import 'package:attendify/features/settings/providers/settings_provider.dart';
import 'package:attendify/database/collections/subject_collection.dart';
import 'package:attendify/features/subjects/providers/subject_providers.dart';
import 'package:attendify/services/notification_service.dart';

class NotificationManagerScreen extends ConsumerWidget {
  const NotificationManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notification Manager',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          final isMasterEnabled = settings.notificationsEnabled;
          return ListView(
            padding: const EdgeInsets.only(bottom: 48),
            children: [
              _buildToggleSection(context, settings, notifier),
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
              Opacity(
                opacity: isMasterEnabled ? 1.0 : 0.4,
                child: AbsorbPointer(
                  absorbing: !isMasterEnabled,
                  child: Column(
                    children: [
                      _buildSubjectPreferencesSection(context, subjects, ref, isMasterEnabled),
                      Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), height: 1),
                      _buildTaskTypePreferencesSection(context, settings, notifier),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildToggleSection(BuildContext context, AppSettings settings, Settings notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GENERAL NOTIFICATIONS',
            style: TextStyle(
              color: Color(0xFF7E73FF),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF7E73FF)),
            ),
            title: Text(
              'Allow Notifications',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Enable scheduled alerts and summaries',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
            ),
            trailing: Switch(
              value: settings.notificationsEnabled,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              activeThumbColor: Theme.of(context).colorScheme.onSurface,
              inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (val) async {
                if (val) {
                  final granted = await NotificationService.instance.requestPermissions();
                  if (granted != true) {
                    // Fail silently or fallback
                  }
                }
                notifier.updateNotificationsEnabled(val);
              },
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.outlineVariant, height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE28C38).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFE28C38)),
            ),
            title: Text(
              'Daily Reminder',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Get a summary of classes every morning',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
            ),
            trailing: Switch(
              value: settings.dailyReminderEnabled,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              activeThumbColor: Theme.of(context).colorScheme.onSurface,
              inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: settings.notificationsEnabled
                  ? (val) => notifier.updateDailyReminderEnabled(val)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPreferencesSection(
      BuildContext context, List<Subject> subjects, WidgetRef ref, bool notificationsEnabled) {
    if (subjects.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CLASS REMINDERS BY SUBJECT',
            style: TextStyle(
              color: Color(0xFF7E73FF),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ...subjects.map((subject) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(subject.colorValue),
                ),
              ),
              title: Text(
                subject.name,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              trailing: Switch(
                value: subject.classNotificationsEnabled,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                activeThumbColor: Theme.of(context).colorScheme.onSurface,
                inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: notificationsEnabled
                    ? (val) async {
                        final repo = ref.read(subjectRepositoryProvider);
                        subject.classNotificationsEnabled = val;
                        await repo.update(subject);
                      }
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskTypePreferencesSection(
      BuildContext context, AppSettings settings, Settings notifier) {
    final allTypes = [
      'assignment',
      'homework',
      'quiz',
      'labFile',
      'practical',
      'viva',
      'assessment',
      'midSem',
      'endSem',
      'project',
      'presentation',
      'seminar',
      'internship',
      'other',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLANNER REMINDERS BY TASK TYPE',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allTypes.map((type) {
              final isEnabled = settings.enabledTaskTypes.contains(type);
              return GestureDetector(
                onTap: settings.notificationsEnabled
                    ? () {
                        final currentList = List<String>.from(settings.enabledTaskTypes);
                        if (!isEnabled) {
                          currentList.add(type);
                        } else {
                          currentList.remove(type);
                        }
                        notifier.updateEnabledTaskTypes(currentList);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEnabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                    boxShadow: isEnabled
                        ? [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEnabled) ...[
                        Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 14),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _getTaskTypeDisplayName(type),
                        style: TextStyle(
                          color: isEnabled ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 12,
                          fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getTaskTypeDisplayName(String typeName) {
    switch (typeName) {
      case 'assignment':
        return 'Assignment';
      case 'homework':
        return 'Homework';
      case 'quiz':
        return 'Quiz';
      case 'labFile':
        return 'Lab File';
      case 'practical':
        return 'Practical';
      case 'viva':
        return 'Viva';
      case 'assessment':
        return 'Assessment';
      case 'midSem':
        return 'Mid Sem';
      case 'endSem':
        return 'End Sem';
      case 'project':
        return 'Project';
      case 'presentation':
        return 'Presentation';
      case 'seminar':
        return 'Seminar';
      case 'internship':
        return 'Internship';
      default:
        return 'Other';
    }
  }
}
