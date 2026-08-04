import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../core/enums/lecture_type.dart';
import '../../../core/errors/app_exception.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../engines/schedule_engine.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/schedule_providers.dart';

class ScheduleFormSheet extends ConsumerStatefulWidget {
  final int? scheduleId;
  final int? dayOfWeek;

  const ScheduleFormSheet({
    super.key,
    this.scheduleId,
    this.dayOfWeek,
  });

  @override
  ConsumerState<ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends ConsumerState<ScheduleFormSheet> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedSubjectId;
  LectureType _selectedType = LectureType.lecture;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _roomController = TextEditingController();
  final _facultyController = TextEditingController();
  late int _dayOfWeek;

  bool _isLoading = true;
  Schedule? _existingSchedule;

  @override
  void initState() {
    super.initState();
    _dayOfWeek = widget.dayOfWeek ?? DayOfWeek.monday.value;
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.scheduleId != null) {
      final repo = ref.read(scheduleRepositoryProvider);
      _existingSchedule = await repo.getById(widget.scheduleId!);

      if (_existingSchedule != null) {
        _selectedSubjectId = _existingSchedule!.subjectId;

        _dayOfWeek = _existingSchedule!.dayOfWeek;
        _selectedType = _existingSchedule!.type;
        _startTime = _parseTime(_existingSchedule!.startTime);
        _endTime = _parseTime(_existingSchedule!.endTime);
        _roomController.text = _existingSchedule!.room ?? '';
        _facultyController.text = _existingSchedule!.facultyOverride ?? '';
      }
    }

    // Preload subjects so it's ready for rendering
    await ref.read(subjectsProvider.future);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _roomController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart
        ? (_startTime ?? const TimeOfDay(hour: 9, minute: 0))
        : (_endTime ?? const TimeOfDay(hour: 10, minute: 0));

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjectId == null) {
      _showError('Please select a subject');
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showError('Please select both start and end times');
      return;
    }

    final startStr = _formatTime(_startTime!);
    final endStr = _formatTime(_endTime!);

    try {
      // Validate time range
      ScheduleEngine.validateTimeRange(startStr, endStr);

      final repo = ref.read(scheduleRepositoryProvider);

      final schedule = _existingSchedule ?? Schedule();
      schedule.subjectId = _selectedSubjectId!;
      schedule.dayOfWeek = _dayOfWeek;
      schedule.type = _selectedType;
      schedule.startTime = startStr;
      schedule.endTime = endStr;
      schedule.room = _roomController.text.trim().isEmpty
          ? null
          : _roomController.text.trim();
      schedule.facultyOverride = _facultyController.text.trim().isEmpty
          ? null
          : _facultyController.text.trim();

      // Check conflicts
      final existingSchedules = await repo.getByDay(_dayOfWeek);
      ScheduleEngine.checkForConflicts(schedule, existingSchedules);

      if (_existingSchedule == null) {
        // Find max order
        int maxOrder = 0;
        if (existingSchedules.isNotEmpty) {
          maxOrder = existingSchedules
                  .map((e) => e.order)
                  .reduce((a, b) => a > b ? a : b) +
              1;
        }
        schedule.order = maxOrder;
        await repo.create(schedule);
      } else {
        await repo.update(schedule);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An unexpected error occurred');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _delete() async {
    if (_existingSchedule != null) {
      final repo = ref.read(scheduleRepositoryProvider);
      await repo.delete(_existingSchedule!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.scheduleId != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final subjectsAsync = ref.watch(subjectsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(
                  top: AppSpacing.sm, bottom: AppSpacing.md),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Class' : 'Add Class',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    tooltip: 'Delete Class',
                    onPressed: _delete,
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Form Content
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: CircularProgressIndicator(),
                  ))
                : SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      top: AppSpacing.md,
                      bottom: AppSpacing.xl + bottomInset,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          subjectsAsync.when(
                            data: (subjects) {
                              if (subjects.isEmpty) {
                                return Text(
                                  'You need to create a subject first.',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error),
                                );
                              }
                              return DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                    labelText: 'Subject *'),
                                initialValue: _selectedSubjectId,
                                isExpanded: true,
                                items: subjects
                                    .map((s) => DropdownMenuItem<int>(
                                          value: s.id,
                                          child: Text(s.name,
                                              overflow: TextOverflow.ellipsis),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedSubjectId = val),
                                validator: (val) =>
                                    val == null ? 'Required' : null,
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) =>
                                const Text('Failed to load subjects'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<DayOfWeek>(
                                  decoration:
                                      const InputDecoration(labelText: 'Day'),
                                  initialValue: DayOfWeek.fromInt(_dayOfWeek),
                                  items: DayOfWeek.weekdays
                                      .map((d) => DropdownMenuItem(
                                          value: d, child: Text(d.label)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _dayOfWeek = val.value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: DropdownButtonFormField<LectureType>(
                                  decoration:
                                      const InputDecoration(labelText: 'Type'),
                                  initialValue: _selectedType,
                                  items: LectureType.values
                                      .map((t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t.name.toUpperCase())))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedType = val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context, true),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Start Time *',
                                      suffixIcon:
                                          Icon(Icons.access_time_outlined),
                                    ),
                                    child: Text(_startTime != null
                                        ? _formatTime(_startTime!)
                                        : 'Select Time'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context, false),
                                  borderRadius: BorderRadius.circular(8),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'End Time *',
                                      suffixIcon:
                                          Icon(Icons.access_time_outlined),
                                    ),
                                    child: Text(_endTime != null
                                        ? _formatTime(_endTime!)
                                        : 'Select Time'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _roomController,
                            decoration: const InputDecoration(
                              labelText: 'Room (Optional)',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _facultyController,
                            decoration: const InputDecoration(
                              labelText: 'Faculty Override (Optional)',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          FilledButton(
                            onPressed: _save,
                            child:
                                Text(isEditing ? 'Save Changes' : 'Add Class'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the schedule form as a bottom sheet
Future<void> showScheduleFormSheet(BuildContext context,
    {int? scheduleId, int? dayOfWeek}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ScheduleFormSheet(
      scheduleId: scheduleId,
      dayOfWeek: dayOfWeek,
    ),
  );
}
