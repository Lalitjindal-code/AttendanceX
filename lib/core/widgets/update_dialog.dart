import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/update_service.dart';
import '../../features/backup/providers/backup_provider.dart';

class UpdateDialog extends ConsumerStatefulWidget {
  final UpdateInfo updateInfo;
  final UpdateService updateService;

  const UpdateDialog({
    Key? key,
    required this.updateInfo,
    required this.updateService,
  }) : super(key: key);

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _isDownloading = false;
  bool _isInstalling = false;
  double _progress = 0.0;
  String? _error;

  void _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });
    
    await ref.read(backupControllerProvider.notifier).createAutoBackup();

    final fileName = 'attendify_update_${widget.updateInfo.latestVersion}.apk';

    widget.updateService.downloadAndInstallUpdate(
      url: widget.updateInfo.apkUrl,
      fileName: fileName,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _progress = 1.0;
            _isInstalling = true;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _error = error;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.updateInfo.isMandatory && !_isDownloading,
      child: AlertDialog(
        title: Text('Update Available (${widget.updateInfo.latestVersion})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.updateInfo.releaseNotes.isNotEmpty) ...[
              Text(
                'What\'s new:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.updateInfo.releaseNotes),
              const SizedBox(height: 16),
            ],
            if (_error != null) ...[
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
            ],
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(_isInstalling ? 'Installing...' : '${(_progress * 100).toStringAsFixed(1)}% Downloaded'),
            ] else ...[
              const Text('A new version of Attendify is available. Do you want to update now?'),
            ]
          ],
        ),
        actions: [
          if (!widget.updateInfo.isMandatory && !_isDownloading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('LATER'),
            ),
          if (!_isDownloading)
            ElevatedButton(
              onPressed: _startDownload,
              child: const Text('UPDATE NOW'),
            ),
        ],
      ),
    );
  }
}
