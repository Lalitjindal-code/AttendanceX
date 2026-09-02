import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../../settings/services/feedback_service.dart';
import '../../schedule/services/schedule_request_service.dart';
import 'package:rxdart/rxdart.dart';

class UserSupportScreen extends ConsumerWidget {
  const UserSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch both streams
    final feedbacksStream = ref.watch(feedbackServiceProvider).getUserFeedbacks();
    final requestsStream = ref.watch(scheduleRequestServiceProvider).watchUserScheduleRequests();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests & Support'),
      ),
      body: StreamBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
        stream: Rx.combineLatest2(
          feedbacksStream, 
          requestsStream, 
          (a, b) => [a, b]
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final feedbacks = snapshot.data?[0].docs ?? [];
          final requests = snapshot.data?[1].docs ?? [];

          // Combine and sort by createdAt
          final allTickets = <Map<String, dynamic>>[];
          
          for (var doc in feedbacks) {
            allTickets.add({
              'id': doc.id,
              'type': 'feedback',
              'data': doc.data(),
            });
          }
          
          for (var doc in requests) {
            allTickets.add({
              'id': doc.id,
              'type': 'request',
              'data': doc.data(),
            });
          }

          allTickets.sort((a, b) {
            final ta = (a['data']['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final tb = (b['data']['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return tb.compareTo(ta); // Descending
          });

          if (allTickets.isEmpty) {
            return Center(
              child: Text(
                'No requests or feedbacks found.',
                style: theme.textTheme.titleMedium,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: allTickets.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final ticket = allTickets[index];
              final id = ticket['id'] as String;
              final type = ticket['type'] as String;
              final data = ticket['data'] as Map<String, dynamic>;

              final timestamp = data['createdAt'] as Timestamp?;
              final dateStr = timestamp != null 
                  ? DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate()) 
                  : '';

              String title = '';
              String status = data['status'] as String? ?? 'new';
              IconData icon = Icons.support_agent;

              if (type == 'feedback') {
                title = 'Feedback: ${data['message']?.toString() ?? 'No message'}';
                icon = Icons.feedback_outlined;
              } else if (type == 'request') {
                final branch = data['branch'] ?? 'Unknown';
                final semester = data['semester'] ?? 'Unknown';
                title = 'Timetable Request: $branch Sem $semester';
                icon = Icons.schedule;
              }

              // Count unread? We can just show total messages
              final messages = data['messages'] as List<dynamic>? ?? [];
              final replyCount = messages.length;

              Color statusColor = Colors.blue;
              if (status == 'resolved' || status == 'approved') statusColor = Colors.green;
              if (status == 'rejected') statusColor = Colors.red;
              if (status == 'new' || status == 'pending') statusColor = Colors.orange;

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(icon, color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Status: ${status.toUpperCase()}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(dateStr, style: const TextStyle(fontSize: 12)),
                      if (replyCount > 0)
                        Text('$replyCount messages in thread', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 12)),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/support/chat', extra: {
                      'id': id,
                      'type': type,
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
