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

              return _AdminFeedbackCard(doc: doc, data: data, theme: theme);
            },
          );
        },
      ),
    );
  }
}

class _AdminFeedbackCard extends ConsumerStatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic> data;
  final ThemeData theme;

  const _AdminFeedbackCard({required this.doc, required this.data, required this.theme});

  @override
  ConsumerState<_AdminFeedbackCard> createState() => _AdminFeedbackCardState();
}

class _AdminFeedbackCardState extends ConsumerState<_AdminFeedbackCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved': return Colors.green;
      case 'new': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final data = widget.data;
    final theme = widget.theme;

    final name = data['name'] as String? ?? 'Anonymous';
    final email = data['email'] as String? ?? 'No Email';
    final message = data['message'] as String? ?? '';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final status = data['status'] as String? ?? 'new';
    final isChatClosed = data['isChatClosed'] as bool? ?? false;
    final timestamp = data['createdAt'] as Timestamp?;
    
    final dateStr = timestamp != null 
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate()) 
        : '';

    // Normalize messages
    final List<Map<String, dynamic>> messages = [];
    final rawMessages = data['messages'] as List<dynamic>? ?? [];
    for (final rm in rawMessages) {
      messages.add(Map<String, dynamic>.from(rm as Map));
    }

    // Sort messages by timestamp
    messages.sort((a, b) {
      final ta = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      final tb = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ta.compareTo(tb);
    });

    return Card(
      elevation: 2,
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text(
          'Status: ${status.toUpperCase()} • $email\n${dateStr}',
          style: TextStyle(
            color: _getStatusColor(status),
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          if (imageUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('View Attachment'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(imageUrl),
            ),
          
          const SizedBox(height: AppSpacing.md),
          if (messages.isNotEmpty)
            Container(
              color: theme.colorScheme.surfaceContainerLow,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: messages.map((m) {
                  final isAdmin = m['sender'] == 'admin';
                  return Align(
                    alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isAdmin 
                            ? theme.colorScheme.primaryContainer 
                            : theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isAdmin ? 12 : 0),
                          bottomRight: Radius.circular(isAdmin ? 0 : 12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAdmin ? 'You' : 'User',
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold,
                              color: isAdmin 
                                ? theme.colorScheme.onPrimaryContainer.withOpacity(0.6)
                                : theme.colorScheme.onSecondaryContainer.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['text']?.toString() ?? '',
                            style: TextStyle(
                              color: isAdmin 
                                ? theme.colorScheme.onPrimaryContainer 
                                : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          if (!isChatClosed)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Type reply...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          final text = _controller.text.trim();
                          if (text.isNotEmpty) {
                            ref.read(feedbackServiceProvider).sendChatMessage(doc.id, 'admin', text);
                            _controller.clear();
                          }
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          ref.read(feedbackServiceProvider).closeChatSession(doc.id);
                        },
                        icon: const Icon(Icons.lock),
                        label: const Text('Close Session'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Text('Session Closed', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
