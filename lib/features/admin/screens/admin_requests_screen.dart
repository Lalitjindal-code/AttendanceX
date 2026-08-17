import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_spacing.dart';
import '../../schedule/services/schedule_request_service.dart';

class AdminRequestsScreen extends ConsumerWidget {
  const AdminRequestsScreen({super.key});

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
        title: const Text('Schedule Requests'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ref.read(scheduleRequestServiceProvider).watchAllScheduleRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No schedule requests yet.',
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
              final branch = data['branch'] ?? 'Unknown';
              final semester = data['semester'] ?? 'Unknown';
              final userEmail = data['userEmail'] ?? 'Legacy Request';
              final imageUrl = data['imageUrl'] ?? '';
              final imageUrls = data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : <String>[];
              final status = data['status'] ?? 'pending';
              final adminMessage = data['adminMessage'] ?? '';
              final userMessage = data['userMessage'] ?? '';
              return _AdminRequestCard(doc: doc, data: data, theme: theme);
            },
          );
        },
      ),
    );
  }
}

class _AdminRequestCard extends ConsumerStatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final Map<String, dynamic> data;
  final ThemeData theme;

  const _AdminRequestCard({required this.doc, required this.data, required this.theme});

  @override
  ConsumerState<_AdminRequestCard> createState() => _AdminRequestCardState();
}

class _AdminRequestCardState extends ConsumerState<_AdminRequestCard> {
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
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final data = widget.data;
    final theme = widget.theme;

    final branch = data['branch'] ?? 'Unknown';
    final semester = data['semester'] ?? 'Unknown';
    final userEmail = data['userEmail'] ?? 'Legacy Request';
    final imageUrl = data['imageUrl'] ?? '';
    final imageUrls = data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : <String>[];
    final status = data['status'] ?? 'pending';
    final adminMessage = data['adminMessage'] ?? '';
    final userMessage = data['userMessage'] ?? '';
    final isChatClosed = data['isChatClosed'] as bool? ?? false;
    final timestamp = data['createdAt'] as Timestamp?;

    // Normalize messages
    final List<Map<String, dynamic>> messages = [];
    if (adminMessage.isNotEmpty) {
      messages.add({
        'sender': 'admin',
        'text': adminMessage,
        'timestamp': timestamp,
      });
    }
    if (userMessage.isNotEmpty) {
      messages.add({
        'sender': 'user',
        'text': userMessage,
        'timestamp': timestamp,
      });
    }
    
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
        title: Text('$branch - Semester $semester'),
        subtitle: Text(
          'Status: ${status.toUpperCase()} • $userEmail',
          style: TextStyle(
            color: _getStatusColor(status),
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          if (imageUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('View Timetable Image'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(imageUrl),
            )
          else if (imageUrls.isNotEmpty)
            ...imageUrls.map((url) => ListTile(
              leading: const Icon(Icons.image),
              title: const Text('View Legacy Image'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(url),
            ))
          else
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No image provided.'),
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
                            ref.read(scheduleRequestServiceProvider).sendChatMessage(doc.id, 'admin', text);
                            _controller.clear();
                          }
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          ref.read(scheduleRequestServiceProvider).closeChatSession(doc.id);
                        },
                        icon: const Icon(Icons.lock),
                        label: const Text('Close Session'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(scheduleRequestServiceProvider)
                              .updateRequestStatus(doc.id, 'approved', '');
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Approve Req'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ref.read(scheduleRequestServiceProvider)
                              .updateRequestStatus(doc.id, 'rejected', '');
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject Req'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
