import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_type.dart';
import '../../../database/collections/academic_task_collection.dart';
import '../../subjects/providers/subject_providers.dart';
import '../providers/planner_provider.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final int? taskId;

  const TaskFormSheet({super.key, this.taskId});

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;
  
  TaskType _selectedType = TaskType.assignment;
  TaskPriority _selectedPriority = TaskPriority.medium;
  int? _selectedSubjectId;
  
  DateTime _dueDate = DateTime.now();
  TimeOfDay? _dueTime;
  
  // Future ready reminder list
  List<int> _reminderOffsets = [60, 1440]; // 1 hour and 1 day before

  bool _isLoading = false;
  AcademicTask? _existingTask;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _notesController = TextEditingController();
    
    if (widget.taskId != null) {
      _loadTask();
    }
  }
  
  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    final repo = ref.read(plannerRepositoryProvider);
    _existingTask = await repo.getById(widget.taskId!);
    
    if (_existingTask != null) {
      _titleController.text = _existingTask!.title;
      _descController.text = _existingTask!.description ?? '';
      _notesController.text = _existingTask!.notes ?? '';
      _selectedType = _existingTask!.type;
      _selectedPriority = _existingTask!.priority;
      _dueDate = _existingTask!.dueDate;
      _reminderOffsets = List.from(_existingTask!.notificationOffsets);
      
      if (_existingTask!.dueTime != null) {
        final parts = _existingTask!.dueTime!.split(':');
        if (parts.length == 2) {
          _dueTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      
      // Load subjects to ensure it is available in UI
      await ref.read(subjectsProvider.future);
      _selectedSubjectId = _existingTask!.subjectId;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a subject')));
      return;
    }

    final task = _existingTask ?? AcademicTask();
    task.title = _titleController.text.trim();
    task.description = _descController.text.trim().isEmpty ? null : _descController.text.trim();
    task.notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    task.type = _selectedType;
    task.priority = _selectedPriority;
    task.subjectId = _selectedSubjectId!;
    task.dueDate = DateTime(_dueDate.year, _dueDate.month, _dueDate.day);
    
    if (_dueTime != null) {
      task.dueTime = '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}';
    } else {
      task.dueTime = null;
    }
    
    task.notificationOffsets = _reminderOffsets;

    ref.read(plannerNotifierProvider.notifier).saveTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskId != null;
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
              margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
                    isEditing ? 'Edit Task' : 'New Task',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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
                ? const Center(child: Padding(
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
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Task Title *', hintText: 'e.g. Chapter 4 Reading'),
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          subjectsAsync.when(
                            data: (subjects) => DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Subject *'),
                              initialValue: _selectedSubjectId,
                              isExpanded: true,
                              items: subjects.map((s) => DropdownMenuItem<int>(
                                value: s.id,
                                child: Text(s.name, overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: (val) => setState(() => _selectedSubjectId = val),
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error loading subjects: $e'),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<TaskType>(
                                  decoration: const InputDecoration(labelText: 'Task Type'),
                                  initialValue: _selectedType,
                                  isExpanded: true,
                                  items: TaskType.values.map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (val) => setState(() => _selectedType = val!),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: DropdownButtonFormField<TaskPriority>(
                                  decoration: const InputDecoration(labelText: 'Priority'),
                                  initialValue: _selectedPriority,
                                  isExpanded: true,
                                  items: TaskPriority.values.map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p.name.toUpperCase(), overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (val) => setState(() => _selectedPriority = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _selectDate,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Due Date *',
                                      suffixIcon: Icon(Icons.calendar_today_outlined),
                                    ),
                                    child: Text(DateFormat('MMM dd, yyyy').format(_dueDate)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectTime,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Time (Opt)',
                                      suffixIcon: Icon(Icons.access_time_outlined),
                                    ),
                                    child: Text(_dueTime?.format(context) ?? 'None'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          TextFormField(
                            controller: _descController,
                            decoration: const InputDecoration(labelText: 'Description (Optional)'),
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(labelText: 'Private Notes (Optional)'),
                            maxLines: 2,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          
                          FilledButton(
                            onPressed: _saveTask,
                            child: Text(isEditing ? 'Save Changes' : 'Create Task'),
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

/// Helper function to show the task form as a bottom sheet
Future<void> showTaskFormSheet(BuildContext context, {int? taskId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent, // Required to show container border radius
    builder: (context) => TaskFormSheet(taskId: taskId),
  );
}
