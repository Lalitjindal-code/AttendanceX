import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../core/enums/lecture_type.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../settings/providers/semester_provider.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../../database/collections/subject_collection.dart';
import '../providers/schedule_providers.dart';
import '../services/ocr_timetable_service.dart';

class OcrImportScreen extends ConsumerStatefulWidget {
  const OcrImportScreen({super.key});

  @override
  ConsumerState<OcrImportScreen> createState() => _OcrImportScreenState();
}

class _OcrImportScreenState extends ConsumerState<OcrImportScreen> {
  File? _selectedImage;
  bool _isProcessing = false;
  bool _isSaving = false;
  String? _rawText;
  // Editable list state
  late List<_EditableEntry> _editableEntries;

  @override
  void initState() {
    super.initState();
    _editableEntries = [];
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
    );
    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _rawText = null;
    });

    await _runOcr();
  }

  Future<void> _runOcr() async {
    if (_selectedImage == null) return;
    setState(() => _isProcessing = true);

    try {
      final parsed = await OcrTimetableService.parseImageAdvanced(_selectedImage!);
      
      // We still want to extract raw text for the error display fallback
      final text = await OcrTimetableService.extractText(_selectedImage!);

      setState(() {
        _rawText = text;
        _editableEntries =
            parsed.map((e) => _EditableEntry.fromParsed(e)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveSchedules() async {
    final semester = ref.read(semesterStateProvider);
    if (semester == null) return;

    final subjects = ref.read(subjectsProvider).valueOrNull ?? [];
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add subjects first before importing.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(scheduleRepositoryProvider);
    int savedCount = 0;

    for (final entry in _editableEntries) {
      if (!entry.isSelected || entry.matchedSubjectId == null) continue;

      final schedule = Schedule()
        ..semesterId = semester.id
        ..subjectId = entry.matchedSubjectId!
        ..dayOfWeek = entry.dayOfWeek
        ..startTime = entry.startTime
        ..endTime = entry.endTime
        ..type = LectureType.lecture
        ..order = 0;

      await repo.create(schedule);
      savedCount++;
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$savedCount schedule(s) saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _addManualEntry() {
    setState(() {
      _editableEntries.add(_EditableEntry(
        isSelected: true,
        subjectName: 'New Subject',
        dayOfWeek: 1,
        startTime: '09:00',
        endTime: '10:00',
      ));
      // if error was showing, clear it so we can see the list
      _rawText ??= ''; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? [];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Timetable from Photo'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_editableEntries.isNotEmpty)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveSchedules,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_rounded),
              label: const Text('Save'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1 — Pick Image
            _buildStepCard(
              step: '1',
              title: 'Choose Timetable Photo',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
            ),

            // Preview selected image
            if (_selectedImage != null) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Processing indicator
            if (_isProcessing) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: AppSpacing.sm),
              const Center(
                  child: Text('Extracting text from image...',
                      style: TextStyle(color: Colors.grey))),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Step 2 — Parsed Results
            if (_editableEntries.isNotEmpty) ...[
              _buildStepCard(
                step: '2',
                title: 'Review & Match Subjects',
                subtitle:
                    'Match detected class names to your subjects and select which to save.',
                child: Column(
                  children: _editableEntries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    return _ParsedEntryTile(
                      entry: e,
                      subjects: subjects,
                      onChanged: (updated) {
                        setState(() => _editableEntries[idx] = updated);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: _addManualEntry,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Add Entry Manually'),
              ),
            ] else if (!_isProcessing && _rawText != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: theme.colorScheme.error, size: 40),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Could not detect schedule entries',
                      style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Make sure the image is clear and includes day names (Mon, Tue...) and times (9:00-10:00). Try retaking the photo.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer
                              .withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: _addManualEntry,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Manually Instead'),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: theme.colorScheme.primary,
                child: Text(step,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _EditableEntry {
  bool isSelected;
  String subjectName;
  int dayOfWeek;
  String startTime;
  String endTime;
  int? matchedSubjectId;

  _EditableEntry({
    required this.isSelected,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.matchedSubjectId,
  });

  factory _EditableEntry.fromParsed(ParsedScheduleEntry e) {
    return _EditableEntry(
      isSelected: true,
      subjectName: e.subjectName,
      dayOfWeek: e.dayOfWeek,
      startTime: e.startTime,
      endTime: e.endTime,
    );
  }

  _EditableEntry copyWith({
    bool? isSelected,
    String? subjectName,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    int? matchedSubjectId,
  }) {
    return _EditableEntry(
      isSelected: isSelected ?? this.isSelected,
      subjectName: subjectName ?? this.subjectName,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      matchedSubjectId: matchedSubjectId ?? this.matchedSubjectId,
    );
  }
}

class _ParsedEntryTile extends StatelessWidget {
  final _EditableEntry entry;
  final List<Subject> subjects;
  final ValueChanged<_EditableEntry> onChanged;

  const _ParsedEntryTile({
    required this.entry,
    required this.subjects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: entry.isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: entry.isSelected,
                onChanged: (v) => onChanged(entry.copyWith(isSelected: v)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.subjectName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        // Day Dropdown
                        DropdownButton<int>(
                          value: entry.dayOfWeek,
                          isDense: true,
                          underline: const SizedBox(),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold),
                          items: DayOfWeek.weekdays
                              .map((d) => DropdownMenuItem(
                                    value: d.value,
                                    child: Text(d.shortLabel),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              onChanged(entry.copyWith(dayOfWeek: val));
                            }
                          },
                        ),
                        const Text('•'),
                        // Start Time
                        InkWell(
                          onTap: () async {
                            final parts = entry.startTime.split(':');
                            final time = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 9,
                                minute: int.tryParse(parts[1]) ?? 0);
                            final newTime = await showTimePicker(
                                context: context, initialTime: time);
                            if (newTime != null) {
                              final hh =
                                  newTime.hour.toString().padLeft(2, '0');
                              final mm =
                                  newTime.minute.toString().padLeft(2, '0');
                              onChanged(entry.copyWith(startTime: '$hh:$mm'));
                            }
                          },
                          child: Text(
                            entry.startTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                        const Text('–'),
                        // End Time
                        InkWell(
                          onTap: () async {
                            final parts = entry.endTime.split(':');
                            final time = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 10,
                                minute: int.tryParse(parts[1]) ?? 0);
                            final newTime = await showTimePicker(
                                context: context, initialTime: time);
                            if (newTime != null) {
                              final hh =
                                  newTime.hour.toString().padLeft(2, '0');
                              final mm =
                                  newTime.minute.toString().padLeft(2, '0');
                              onChanged(entry.copyWith(endTime: '$hh:$mm'));
                            }
                          },
                          child: Text(
                            entry.endTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Subject matcher dropdown
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Match to Subject',
              labelStyle: TextStyle(
                  fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            isExpanded: true,
            initialValue: entry.matchedSubjectId,
            hint: const Text('Select a subject', style: TextStyle(fontSize: 12)),
            items: subjects
                .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (val) => onChanged(entry.copyWith(matchedSubjectId: val)),
          ),
        ],
      ),
    );
  }
}
