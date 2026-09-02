import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../../settings/services/feedback_service.dart';
import '../../schedule/services/schedule_request_service.dart';

class TicketChatScreen extends ConsumerStatefulWidget {
  final String ticketId;
  final String ticketType;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    required this.ticketType,
  });

  @override
  ConsumerState<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends ConsumerState<TicketChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getStream() {
    final firestore = FirebaseFirestore.instance;
    final collection = widget.ticketType == 'feedback' ? 'feedbacks' : 'schedule_requests';
    return firestore.collection(collection).doc(widget.ticketId).snapshots();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    if (widget.ticketType == 'feedback') {
      await ref.read(feedbackServiceProvider).sendChatMessage(widget.ticketId, 'user', text);
    } else {
      await ref.read(scheduleRequestServiceProvider).sendChatMessage(widget.ticketId, 'user', text);
    }
    
    // Auto-scroll after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticketType == 'feedback' ? 'Feedback Chat' : 'Request Chat'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return const Center(child: Text('Ticket not found'));
          }

          final data = doc.data()!;
          final isChatClosed = data['isChatClosed'] as bool? ?? false;
          
          final messages = <Map<String, dynamic>>[];
          
          // Legacy admin/user messages (schedule_requests)
          final adminMessage = data['adminMessage'] as String? ?? '';
          final userMessage = data['userMessage'] as String? ?? '';
          final timestamp = data['createdAt'] as Timestamp?;

          if (adminMessage.isNotEmpty) {
            messages.add({'sender': 'admin', 'text': adminMessage, 'timestamp': timestamp});
          }
          if (userMessage.isNotEmpty) {
            messages.add({'sender': 'user', 'text': userMessage, 'timestamp': timestamp});
          }

          // New chat messages
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

          // Scroll to bottom on new data
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isUser = m['sender'] == 'user';
                    final time = (m['timestamp'] as Timestamp?)?.toDate();
                    final timeStr = time != null ? DateFormat('hh:mm a').format(time) : '';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              m['text']?.toString() ?? '',
                              style: TextStyle(
                                color: isUser 
                                  ? theme.colorScheme.onPrimary 
                                  : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (timeStr.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isUser 
                                    ? theme.colorScheme.onPrimary.withOpacity(0.7) 
                                    : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Input Area
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: theme.colorScheme.surface,
                child: isChatClosed
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text('This ticket has been closed.', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHigh,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: IconButton(
                              icon: Icon(Icons.send, color: theme.colorScheme.onPrimary, size: 18),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
