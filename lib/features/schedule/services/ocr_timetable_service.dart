import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Represents a single parsed schedule entry extracted from a timetable image.
class ParsedScheduleEntry {
  final String subjectName;
  final int dayOfWeek; // 1=Mon ... 7=Sun
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final String? room;

  ParsedScheduleEntry({
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  ParsedScheduleEntry copyWith({
    String? subjectName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return ParsedScheduleEntry(
      subjectName: subjectName ?? this.subjectName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }
}

class OcrTimetableService {
  static final _textRecognizer = TextRecognizer();

  static const _dayMap = {
    'mon': 1, 'monday': 1,
    'tue': 2, 'tues': 2, 'tuesday': 2,
    'wed': 3, 'wednesday': 3,
    'thu': 4, 'thur': 4, 'thurs': 4, 'thursday': 4,
    'fri': 5, 'friday': 5,
    'sat': 6, 'saturday': 6,
    'sun': 7, 'sunday': 7,
  };

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Extracts raw text from the given image file using MLKit.
  static Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Advanced 2D Spatial Grid Parsing
  /// Uses ML Kit's bounding boxes to accurately map classes to Days and Times.
  static Future<List<ParsedScheduleEntry>> parseImageAdvanced(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    final timePattern = RegExp(r'(\d{1,2}[:\.]\d{2})\s*[-–to]+\s*(\d{1,2}[:\.]\d{2})');
    final courseCodePattern = RegExp(r'\b[A-Za-z]{2,4}[-\s]?\d{3,4}\b');
    
    final List<Map<String, dynamic>> timeColumns = [];
    final List<Map<String, dynamic>> dayRows = [];
    final List<TextLine> courseLines = [];
    
    // 1. Identify Columns (Times), Rows (Days), and Cells (Courses)
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.toLowerCase().trim();
        
        // Is it a Time Header?
        final timeMatch = timePattern.firstMatch(text);
        if (timeMatch != null) {
          timeColumns.add({
            'start': _normalizeTime(timeMatch.group(1)!),
            'end': _normalizeTime(timeMatch.group(2)!),
            'rect': line.boundingBox,
          });
          continue;
        }
        
        // Is it a Day Header?
        bool isDay = false;
        for (final entry in _dayMap.entries) {
          if (text == entry.key || text.startsWith('${entry.key} ') || text.startsWith('${entry.key}:')) {
            dayRows.add({
              'day': entry.value,
              'rect': line.boundingBox,
            });
            isDay = true;
            break;
          }
        }
        if (isDay) continue;
        
        // Does it contain a course code?
        if (courseCodePattern.hasMatch(text)) {
          courseLines.add(line);
        }
      }
    }
    
    final entries = <ParsedScheduleEntry>[];
    
    // 2. Map Cells to nearest Row and Column
    for (final line in courseLines) {
      final box = line.boundingBox;
      final centerX = box.left + (box.width / 2);
      final centerY = box.top + (box.height / 2);
      
      int? matchedDay;
      double minDy = double.infinity;
      for (final row in dayRows) {
        final Rect rowBox = row['rect'];
        final rowCenterY = rowBox.top + (rowBox.height / 2);
        final dy = (centerY - rowCenterY).abs();
        if (dy < minDy) {
          minDy = dy;
          matchedDay = row['day'];
        }
      }
      
      String matchedStart = '09:00';
      String matchedEnd = '10:00';
      double minDx = double.infinity;
      for (final col in timeColumns) {
        final Rect colBox = col['rect'];
        final colCenterX = colBox.left + (colBox.width / 2);
        final dx = (centerX - colCenterX).abs();
        if (dx < minDx) {
          minDx = dx;
          matchedStart = col['start'];
          matchedEnd = col['end'];
        }
      }
      
      final matches = courseCodePattern.allMatches(line.text);
      for (final match in matches) {
        String subject = match.group(0)!.toUpperCase();
        
        final remainder = line.text.substring(match.end).toLowerCase().trimLeft();
        if (remainder.startsWith('lab') || remainder.startsWith('-lab')) {
           subject += ' LAB';
        }
        
        entries.add(ParsedScheduleEntry(
          subjectName: subject,
          dayOfWeek: matchedDay ?? 1, 
          startTime: matchedStart,
          endTime: matchedEnd,
        ));
      }
    }
    
    // Deduplicate
    final unique = <String, ParsedScheduleEntry>{};
    for (var e in entries) {
      final key = '${e.dayOfWeek}_${e.startTime}_${e.subjectName}';
      if (!unique.containsKey(key)) {
        unique[key] = e;
      }
    }
    
    // 3. Fallback if Spatial Parsing found nothing
    if (unique.isEmpty) {
       return parseText(recognizedText.text);
    }
    
    final result = unique.values.toList();
    result.sort((a, b) {
      final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
      if (dayCompare != 0) return dayCompare;
      return a.startTime.compareTo(b.startTime);
    });
    
    return result;
  }

  /// Tries to parse a list of schedule entries from extracted OCR text.
  /// Returns entries sorted by day and time.
  static List<ParsedScheduleEntry> parseText(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final entries = <ParsedScheduleEntry>[];

    // Strategy: Look for patterns like "Day SubjectName Time"
    // Examples: "Mon Data Structures 9:00-10:00", "Tuesday OS Lab 10:00 - 11:30"
    final timePattern = RegExp(
        r'(\d{1,2}[:\.]\d{2})\s*(?:AM|PM|am|pm)?\s*[-–to]+\s*(\d{1,2}[:\.]\d{2})\s*(?:AM|PM|am|pm)?');
    
    int? currentDay;

    for (final line in lines) {
      final lowerLine = line.toLowerCase();

      // Check if this line is a day header
      for (final entry in _dayMap.entries) {
        if (lowerLine == entry.key ||
            lowerLine.startsWith('${entry.key} ') ||
            lowerLine.startsWith('${entry.key}:')) {
          currentDay = entry.value;
          break;
        }
      }

      // Try to find a time range in this line
      final timeMatch = timePattern.firstMatch(line);
      if (timeMatch != null && currentDay != null) {
        final startRaw = timeMatch.group(1)!;
        final endRaw = timeMatch.group(2)!;

        // Extract subject name: everything before the time pattern, minus day names
        var subjectPart = line.substring(0, timeMatch.start).trim();

        // Remove day name prefix if present
        for (final dayName in _dayNames) {
          if (subjectPart.toLowerCase().startsWith(dayName.toLowerCase())) {
            subjectPart = subjectPart.substring(dayName.length).trim();
            break;
          }
        }
        // Also try removing full day names
        for (final dayKey in _dayMap.keys) {
          if (subjectPart.toLowerCase().startsWith(dayKey)) {
            subjectPart = subjectPart.substring(dayKey.length).trim();
            break;
          }
        }
        
        // Clean up common separators
        subjectPart = subjectPart.replaceAll(RegExp(r'^[-:,]+'), '').trim();

        if (subjectPart.isNotEmpty && subjectPart.length >= 2) {
          entries.add(ParsedScheduleEntry(
            subjectName: _cleanSubjectName(subjectPart),
            dayOfWeek: currentDay,
            startTime: _normalizeTime(startRaw),
            endTime: _normalizeTime(endRaw),
          ));
        }
      }
    }

    // If we have no entries, try a different strategy: whole-text scanning
    if (entries.isEmpty) {
      entries.addAll(_tryGlobalParse(lines));
    }

    // Grid fallback
    if (entries.isEmpty) {
      entries.addAll(_tryGridParse(lines));
    }

    // Sort by day then start time
    entries.sort((a, b) {
      final dayCompare = a.dayOfWeek.compareTo(b.dayOfWeek);
      if (dayCompare != 0) return dayCompare;
      return a.startTime.compareTo(b.startTime);
    });

    return entries;
  }

  /// Secondary strategy: scans each line independently for day+time patterns.
  static List<ParsedScheduleEntry> _tryGlobalParse(List<String> lines) {
    final entries = <ParsedScheduleEntry>[];
    final timePattern = RegExp(
        r'(\d{1,2}[:\.]\d{2})\s*(?:AM|PM|am|pm)?\s*[-–to]+\s*(\d{1,2}[:\.]\d{2})\s*(?:AM|PM|am|pm)?');

    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      int? foundDay;

      for (final entry in _dayMap.entries) {
        if (lowerLine.contains(entry.key)) {
          foundDay = entry.value;
          break;
        }
      }

      if (foundDay == null) continue;

      final timeMatch = timePattern.firstMatch(line);
      if (timeMatch != null) {
        var subjectPart = line
            .replaceAll(timeMatch.group(0)!, '')
            .trim();
        for (final dayKey in _dayMap.keys) {
          subjectPart = subjectPart.replaceAll(
              RegExp(dayKey, caseSensitive: false), '');
        }
        subjectPart = subjectPart.replaceAll(RegExp(r'[-:,|]+'), ' ').trim();

        if (subjectPart.length >= 2) {
          entries.add(ParsedScheduleEntry(
            subjectName: _cleanSubjectName(subjectPart),
            dayOfWeek: foundDay,
            startTime: _normalizeTime(timeMatch.group(1)!),
            endTime: _normalizeTime(timeMatch.group(2)!),
          ));
        }
      }
    }
    return entries;
  }

  /// Third strategy: Grid fallback. Extracts course codes (e.g. AI-302, CS101) 
  /// and attempts to associate them with the last seen day.
  static List<ParsedScheduleEntry> _tryGridParse(List<String> lines) {
    final entries = <ParsedScheduleEntry>[];
    int? currentDay;
    
    // Regex for common college course codes: 2-4 letters, optional dash/space, 3-4 digits.
    final courseCodePattern = RegExp(r'\b[A-Za-z]{2,4}[-\s]?\d{3,4}\b');
    
    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      
      // Determine if the line starts with or is a day
      for (final entry in _dayMap.entries) {
        if (lowerLine == entry.key || lowerLine.startsWith('${entry.key} ') || lowerLine.startsWith('${entry.key}:')) {
          currentDay = entry.value;
          break;
        }
      }
      
      // Find all course codes in this line
      final matches = courseCodePattern.allMatches(line);
      for (final match in matches) {
        String subject = match.group(0)!.toUpperCase();
        
        // Grab context if it's a lab
        final remainder = line.substring(match.end).toLowerCase().trimLeft();
        if (remainder.startsWith('lab') || remainder.startsWith('-lab')) {
           subject += ' LAB';
        }
        
        entries.add(ParsedScheduleEntry(
          subjectName: subject,
          dayOfWeek: currentDay ?? 1, // Default to Monday if no day seen
          startTime: '09:00',
          endTime: '10:00',
        ));
      }
    }
    
    // Deduplicate entries that might have been picked up multiple times
    // (e.g., if a 2-hour class is written twice)
    final unique = <String, ParsedScheduleEntry>{};
    for (var e in entries) {
      final key = '${e.dayOfWeek}_${e.subjectName}';
      if (!unique.containsKey(key)) {
        unique[key] = e;
      }
    }
    
    return unique.values.toList();
  }

  static String _cleanSubjectName(String raw) {
    return raw
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  /// Normalizes "9:00", "09:00", "9.00" to "09:00".
  static String _normalizeTime(String raw) {
    final cleaned = raw.replaceAll('.', ':').trim();
    final parts = cleaned.split(':');
    if (parts.length < 2) return '09:00';
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
