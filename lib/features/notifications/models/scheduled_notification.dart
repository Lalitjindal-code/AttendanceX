import 'package:flutter/foundation.dart';

/// Represents a single notification to be scheduled locally.
@immutable
class ScheduledNotification {
  /// Unique deterministic ID for this notification.
  final int id;
  
  /// The title of the notification.
  final String title;
  
  /// The body content of the notification.
  final String body;
  
  /// The local time when this notification should be triggered.
  final DateTime scheduledDate;
  
  /// Optional payload for routing when the user taps the notification.
  final String? payload;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    this.payload,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ScheduledNotification &&
      other.id == id &&
      other.title == title &&
      other.body == body &&
      other.scheduledDate == scheduledDate &&
      other.payload == payload;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      body.hashCode ^
      scheduledDate.hashCode ^
      payload.hashCode;
  }
}
