import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/backup_provider.dart';
import '../../settings/providers/settings_provider.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final _dateFormat = DateFormat('MMM d, yyyy - hh:mm a');

  Future<void> _handleCreateBackup() async {
    try {
      String? outputFile;

      if (Platform.isAndroid || Platform.isIOS) {
        // Use file picker to save file securely without broad storage permissions
        final result = await FilePicker.platform.getDirectoryPath();
        if (result == null) return; // User canceled
        final fileName =
            'Attendify_Backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.atfy';
        outputFile = '$result/$fileName';
      } else {
        // Desktop platforms
        outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Backup File',
          fileName:
              'Attendify_Backup_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.atfy',
          type: FileType.custom,
          allowedExtensions: ['atfy'],
        );
        if (outputFile == null) return;
      }

      await ref
          .read(backupControllerProvider.notifier)
          .createBackup(outputFile);
      await ref
          .read(settingsProvider.notifier)
          .updateLastBackupDate(DateTime.now());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup created successfully at $outputFile')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create backup: $e')),
        );
      }
    }
  }

  Future<void> _handleRestoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Android sometimes ignores custom extensions
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) throw Exception('Unable to access file path.');

      if (!path.endsWith('.atfy')) {
        throw Exception('Please select a valid Attendify backup file (.atfy)');
      }

      final controller = ref.read(backupControllerProvider.notifier);

      // Get preview
      final preview = await controller.getPreview(path);

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            icon:
                Icon(Icons.restore, color: theme.colorScheme.onSurfaceVariant),
            title: const Text('Restore This Backup?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${_dateFormat.format(preview.createdAt)}',
                    style: theme.textTheme.bodyMedium),
                Text('App Version: ${preview.appVersion}',
                    style: theme.textTheme.bodyMedium),
                Text('Platform: ${preview.platform}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(
                  'Current data will be replaced. Rollback backup auto-created.',
                  style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        await controller.restoreBackup(path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore completed successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final backupProgress = ref.watch(backupControllerProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Storage & Backup')),
      body: backupProgress != null
          ? _buildProgressState(backupProgress, theme)
          : ListView(
              children: [
                _buildDataSafetyCard(settings.lastBackupDate, theme),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Create Backup'),
                  subtitle: const Text('Save to .atfy file'),
                  onTap: _handleCreateBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore from file'),
                  subtitle: const Text('Import .atfy backup'),
                  onTap: _handleRestoreBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_off),
                  title: const Text('Cloud Backup'),
                  trailing: Chip(
                    label: const Text('Coming Soon'),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    side: BorderSide.none,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  ),
                  enabled: false,
                ),
              ],
            ),
    );
  }

  Widget _buildDataSafetyCard(DateTime? lastBackupDate, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: theme.colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data is safe.',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: lastBackupDate != null
                                ? Colors.green
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastBackupDate != null
                              ? 'Last backup: ${_dateFormat.format(lastBackupDate)}'
                              : 'No recent backup',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressState(double progress, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress > 0 ? progress : null,
              strokeWidth: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Processing data...',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
