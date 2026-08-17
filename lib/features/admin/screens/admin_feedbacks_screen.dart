import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../../settings/services/feedback_service.dart';

class AdminFeedbacksScreen extends ConsumerWidget {
  const AdminFeedbacksScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedbacks'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ref.read(feedbackServiceProvider).watchAllFeedbacks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var docs = snapshot.data?.docs ?? [];
          
          // Local sorting to avoid missing index errors
          docs.sort((a, b) {
            final ta = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final tb = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return tb.compareTo(ta); // Descending
          });

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No feedbacks yet.',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              
              final name = data['name'] as String? ?? 'Anonymous';
              final email = data['email'] as String? ?? 'No Email';
              final message = data['message'] as String? ?? '';
              final imageUrl = data['imageUrl'] as String? ?? '';
              final timestamp = data['createdAt'] as Timestamp?;
              
              final dateStr = timestamp != null 
                  ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate()) 
                  : '';

              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          if (dateStr.isNotEmpty)
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
                      ),
                      const Divider(height: 24),
                      Text(
                        message,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (imageUrl.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _launchUrl(imageUrl),
                            child: Image.network(
                              imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                width: double.infinity,
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Center(child: Icon(Icons.broken_image)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _launchUrl(imageUrl),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('View Full Image'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
