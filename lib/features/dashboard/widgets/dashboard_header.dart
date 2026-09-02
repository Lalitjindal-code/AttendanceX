import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../navigation/app_routes.dart';
import 'header_illustration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:attendify/services/notification_service.dart';
import 'package:attendify/features/sync/services/firebase_sync_service.dart';

class DashboardHeader extends StatefulWidget {
  final String? subtitle;
  final String userName;
  final String? photoUrl;

  const DashboardHeader({
    super.key,
    this.subtitle,
    required this.userName,
    this.photoUrl,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  late Timer _timer;
  late DateTime _now;
  int _pendingNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _loadPendingNotificationsCount();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
        if (timer.tick % 60 == 0) {
          _loadPendingNotificationsCount();
        }
      }
    });
  }

  Future<void> _loadPendingNotificationsCount() async {
    try {
      final notifications =
          await NotificationService.instance.getPendingNotifications();
      if (mounted) {
        setState(() {
          _pendingNotificationsCount = notifications.length;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm').format(_now);
    final amPmStr = DateFormat('a').format(_now);
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(_now);

    final firstName = widget.userName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Greeting, Notification
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push(AppRoutes.profile),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: widget.photoUrl != null
                      ? NetworkImage(widget.photoUrl!)
                      : null,
                  child: widget.photoUrl == null
                      ? Icon(Icons.person,
                          color: Theme.of(context).colorScheme.onPrimary)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey there,',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            firstName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('👋', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final syncState = ref.watch(syncStateProvider);
                  IconData icon;
                  Color color;
                  bool isSpinning = false;
                  String tooltip;

                  switch (syncState) {
                    case SyncState.online:
                      icon = Icons.cloud_done_rounded;
                      color = Colors.green;
                      tooltip = 'Online & Synced';
                      break;
                    case SyncState.offline:
                      icon = Icons.cloud_off_rounded;
                      color = Colors.red;
                      tooltip = 'Offline';
                      break;
                    case SyncState.syncing:
                      icon = Icons.sync_rounded;
                      color = Theme.of(context).colorScheme.primary;
                      isSpinning = true;
                      tooltip = 'Syncing...';
                      break;
                  }

                  Widget iconWidget = Icon(icon, color: color, size: 24);
                  if (isSpinning) {
                    iconWidget = iconWidget
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 2.seconds);
                  }

                  return Tooltip(
                    message: tooltip,
                    child: IconButton(
                      icon: iconWidget,
                      onPressed: () {},
                    ),
                  );
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      _pendingNotificationsCount > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 28,
                    ),
                    onPressed: () async {
                      await context.push(AppRoutes.notifications);
                      _loadPendingNotificationsCount();
                    },
                  ),
                  if (_pendingNotificationsCount > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Bottom Row: Time/Date and Illustration
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            amPmStr,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const HeaderIllustration(),
            ],
          ),
        ],
      ),
    );
  }
}
