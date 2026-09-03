import 'package:flutter/material.dart';

class WhatsNewDialog extends StatelessWidget {
  final String releaseNotes;
  final String version;

  const WhatsNewDialog({
    Key? key,
    required this.releaseNotes,
    required this.version,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.new_releases_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('What\'s New!'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Version $version',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              releaseNotes.isNotEmpty ? releaseNotes : 'Bug fixes and performance improvements.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Awesome!'),
        ),
      ],
    );
  }
}
