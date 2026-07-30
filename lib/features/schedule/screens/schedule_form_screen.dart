import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../core/enums/lecture_type.dart';
import '../../../core/errors/app_exception.dart';
import '../../../database/collections/schedule_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/schedule_engine.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/schedule_providers.dart';

class ScheduleFormScreen extends ConsumerStatefulWidget {
  final int? scheduleId;
  final int? dayOfWeek;

  const ScheduleFormScreen({
    super.key,
    this.scheduleId,
    this.dayOfWeek,
  });

  @override
  ConsumerState<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends ConsumerState<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Subject? _selectedSubject;
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
        final subjectRepo = ref.read(subjectRepositoryProvider);
        _selectedSubject = await subjectRepo.getById(_existingSchedule!.subjectId);
        
        _dayOfWeek = _existingSchedule!.dayOfWeek;
        _selectedType = _existingSchedule!.type;
        _startTime = _parseTime(_existingSchedule!.startTime);
        _endTime = _parseTime(_existingSchedule!.endTime);
        _roomController.text = _existingSchedule!.room ?? '';
        _facultyController.text = _existingSchedule!.facultyOverride ?? '';
      }
    }
    
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
    
    if (_selectedSubject == null) {
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
      schedule.subjectId = _selectedSubject!.id;
      schedule.dayOfWeek = _dayOfWeek;
      schedule.type = _selectedType;
      schedule.startTime = startStr;
      schedule.endTime = endStr;
      schedule.room = _roomController.text.trim().isEmpty ? null : _roomController.text.trim();
      schedule.facultyOverride = _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim();

      // Check conflicts
      final existingSchedules = await repo.getByDay(_dayOfWeek);
      ScheduleEngine.checkForConflicts(schedule, existingSchedules);

      if (_existingSchedule == null) {
        // Find max order
        int maxOrder = 0;
        if (existingSchedules.isNotEmpty) {
          maxOrder = existingSchedules.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;
        }
        schedule.order = maxOrder;
        await repo.create(schedule);
      } else {
        await repo.update(schedule);
      }

      if (mounted) {
        context.pop();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_existingSchedule == null ? 'Add Schedule' : 'Edit Schedule'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            subjectsAsync.when(
              data: (subjects) {
                return DropdownButtonFormField<Subject>(
                  decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                  initialValue: _selectedSubject,
                  items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                  onChanged: (val) => setState(() => _selectedSubject = val),
                  validator: (val) => val == null ? 'Please select a subject' : null,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Failed to load subjects'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DayOfWeek>(
              decoration: const InputDecoration(labelText: 'Day', border: OutlineInputBorder()),
              initialValue: DayOfWeek.fromInt(_dayOfWeek),
              items: DayOfWeek.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _dayOfWeek = val.value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<LectureType>(
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              initialValue: _selectedType,
              items: LectureType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Start Time', border: OutlineInputBorder()),
                      child: Text(_startTime != null ? _formatTime(_startTime!) : 'Select Time'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'End Time', border: OutlineInputBorder()),
                      child: Text(_endTime != null ? _formatTime(_endTime!) : 'Select Time'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Room (Optional)', border: OutlineInputBorder()),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _facultyController,
              decoration: const InputDecoration(labelText: 'Faculty Override (Optional)', border: OutlineInputBorder()),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
