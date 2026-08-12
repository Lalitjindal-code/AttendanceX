import 'dart:async';
import 'package:flutter/material.dart';
import '../models/dashboard_state.dart';

class NextClassCard extends StatefulWidget {
  final LectureCardModel lecture;
  final VoidCallback onMarkAttendance;

  const NextClassCard({
    super.key,
    required this.lecture,
    required this.onMarkAttendance,
  });

  @override
  State<NextClassCard> createState() => _NextClassCardState();
}

class _NextClassCardState extends State<NextClassCard> {
  Timer? _timer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final scheduleTime = widget.lecture.schedule.startTime;

    final hour = int.parse(scheduleTime.split(':')[0]);
    final minute = int.parse(scheduleTime.split(':')[1]);

    final lectureDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    final difference = lectureDate.difference(now);

    if (difference.isNegative) {
      if (mounted) setState(() => _countdownText = 'Started');
    } else if (difference.inHours > 0) {
      if (mounted) {
        setState(() => _countdownText =
            'Starts in ${difference.inHours}h ${difference.inMinutes.remainder(60)}m');
      }
    } else {
      if (mounted) {
        setState(
            () => _countdownText = 'Starts in ${difference.inMinutes} minutes');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onMarkAttendance,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            size: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Next Class',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _countdownText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lecture.subject.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.lecture.schedule.startTime} - ${widget.lecture.schedule.endTime}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.9),
                          ),
                    ),
                    if (widget.lecture.schedule.room != null &&
                        widget.lecture.schedule.room!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.room_rounded,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.lecture.schedule.room!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
