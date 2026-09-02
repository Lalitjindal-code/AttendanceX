import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminRemindersScreen extends StatefulWidget {
  const AdminRemindersScreen({super.key});

  @override
  State<AdminRemindersScreen> createState() => _AdminRemindersScreenState();
}

class _AdminRemindersScreenState extends State<AdminRemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController(text: 'https://attendify-backend-one.vercel.app/api/remind');
  String _selectedTarget = 'all';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _sendReminders() async {
    final apiUrl = _urlController.text.trim();
    final customMessage = _messageController.text.trim();
    final customTitle = _titleController.text.trim();

    if (apiUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API URL cannot be empty')),
      );
      return;
    }

    if (customMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message cannot be empty')),
      );
      return;
    }

    setState(() => _isSending = true);
    bool success = false;
    String responseMessage = '';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': customTitle.isNotEmpty ? customTitle : 'Reminder',
          'message': customMessage,
          'target': _selectedTarget,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        success = true;
        responseMessage = data['message'] ?? 'Reminders sent successfully!';
      } else {
        responseMessage = 'Failed: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      responseMessage = 'Error: $e';
    } finally {
      // Save history to Firestore
      try {
        await FirebaseFirestore.instance.collection('sent_reminders').add({
          'title': customTitle.isNotEmpty ? customTitle : 'Reminder',
          'message': customMessage,
          'target': _selectedTarget,
          'apiUrl': apiUrl,
          'sentAt': FieldValue.serverTimestamp(),
          'success': success,
          'response': responseMessage,
        });
      } catch (e) {
        debugPrint('Failed to save history: $e');
      }

      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseMessage),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (success) {
          _messageController.clear();
          _titleController.clear();
          _tabController.animateTo(1); // Switch to history tab on success
        }
      }
    }
  }

  Widget _buildSendSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.campaign_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Compose Notification',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send push notifications to users. You can customize the title and message.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Notification Title (Optional)',
                      hintText: 'e.g., Action Required',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'e.g., Please complete your profile as soon as possible.',
                      prefixIcon: const Icon(Icons.message),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTarget,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Target Audience',
                      prefixIcon: const Icon(Icons.group),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('All Users'),
                      ),
                      DropdownMenuItem(
                        value: 'incomplete',
                        child: Text('Users with Incomplete Profiles', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTarget = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'API Configuration',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Vercel API URL',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSending ? null : _sendReminders,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSending ? 'Sending Notification...' : 'Send Notification',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sent_reminders')
          .orderBy('sentAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 64, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                const SizedBox(height: 16),
                Text(
                  'No message history found.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'Reminder';
            final message = data['message'] as String? ?? '';
            final target = data['target'] as String? ?? 'all';
            final success = data['success'] as bool? ?? false;
            final response = data['response'] as String? ?? '';
            final timestamp = data['sentAt'] as Timestamp?;
            final dateStr = timestamp != null
                ? DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp.toDate())
                : 'Unknown date';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: success ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(
                    success ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: success ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  dateStr,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.isNotEmpty) ...[
                          Text('Message:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(message, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 16),
                        ],
                        Text('Target:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(target == 'all' ? 'All Users' : 'Incomplete Profiles', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Text('Response:', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(response, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: success ? Colors.green[700] : Colors.red[700])),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.send_rounded), text: 'Send'),
            Tab(icon: Icon(Icons.history_rounded), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendSection(),
          _buildHistorySection(),
        ],
      ),
    );
  }
}
