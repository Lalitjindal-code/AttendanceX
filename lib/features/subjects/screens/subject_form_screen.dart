import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/subject_validator.dart';
import '../providers/subject_providers.dart';
import '../widgets/subject_color_picker.dart';

class SubjectFormSheet extends ConsumerStatefulWidget {
  final int? subjectId;

  const SubjectFormSheet({super.key, this.subjectId});

  @override
  ConsumerState<SubjectFormSheet> createState() => _SubjectFormSheetState();
}

class _SubjectFormSheetState extends ConsumerState<SubjectFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _facultyNameController = TextEditingController();
  final _facultyEmailController = TextEditingController();
  final _facultyPhoneController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  final _goalController = TextEditingController(text: '75.0');
  final _notesController = TextEditingController();
  int _selectedColor = SubjectColorPicker.defaultColors[0];

  bool _isLoading = false;
  Subject? _existingSubject;

  @override
  void initState() {
    super.initState();
    if (widget.subjectId != null) {
      _loadSubject();
    }
  }

  Future<void> _loadSubject() async {
    setState(() => _isLoading = true);
    try {
      final subject = await ref.read(subjectRepositoryProvider).getById(widget.subjectId!);
      if (subject != null) {
        _existingSubject = subject;
        _nameController.text = subject.name;
        _facultyNameController.text = subject.facultyName ?? '';
        _facultyEmailController.text = subject.facultyEmail ?? '';
        _facultyPhoneController.text = subject.facultyPhone ?? '';
        _creditsController.text = subject.credits.toString();
        _goalController.text = subject.goalPercentage.toString();
        _notesController.text = subject.notes ?? '';
        _selectedColor = subject.colorValue;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facultyNameController.dispose();
    _facultyEmailController.dispose();
    _facultyPhoneController.dispose();
    _creditsController.dispose();
    _goalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final repo = ref.read(subjectRepositoryProvider);

    final subject = _existingSubject ?? Subject();
    subject.name = _nameController.text;
    subject.facultyName = _facultyNameController.text.trim().isEmpty ? null : _facultyNameController.text.trim();
    subject.facultyEmail = _facultyEmailController.text.trim().isEmpty ? null : _facultyEmailController.text.trim();
    subject.facultyPhone = _facultyPhoneController.text.trim().isEmpty ? null : _facultyPhoneController.text.trim();
    subject.credits = int.parse(_creditsController.text.trim());
    subject.goalPercentage = double.parse(_goalController.text.trim());
    subject.notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    subject.colorValue = _selectedColor;

    try {
      if (widget.subjectId == null) {
        await repo.create(subject);
      } else {
        await repo.update(subject);
      }
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.subjectId == null) return;
    
    final repo = ref.read(subjectRepositoryProvider);
    final impact = await repo.getDeletionImpact(widget.subjectId!);
    
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('This subject contains:\n\n'
            'â€¢ ${impact.schedulesCount} schedule entries\n'
            'â€¢ ${impact.attendancesCount} attendance records\n'
            'â€¢ ${impact.historyCount} attendance history records\n\n'
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await repo.deletePermanently(widget.subjectId!);
      if (mounted) {
        Navigator.of(context).pop(); // Pop form sheet
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subjectId != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), // radius2XL equivalent
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
                    isEditing ? 'Edit Subject' : 'Add Subject',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete Subject',
                    color: Theme.of(context).colorScheme.error,
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
          // Content
          Flexible(
            child: _isLoading
                ? const Center(child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(),
                ))
                : SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                        top: AppSpacing.md,
                        bottom: AppSpacing.xl,
                      ),
                      child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Subject Name *', hintText: 'e.g. Data Structures'),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: SubjectValidator.validateName,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _creditsController,
                                  decoration: const InputDecoration(labelText: 'Credits *'),
                                  keyboardType: TextInputType.number,
                                  validator: SubjectValidator.validateCredits,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: TextFormField(
                                  controller: _goalController,
                                  decoration: const InputDecoration(labelText: 'Goal % *'),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: SubjectValidator.validateGoal,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          
                          Text('Subject Color', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.md),
                          SubjectColorPicker(
                            selectedColor: _selectedColor,
                            onColorSelected: (color) => setState(() => _selectedColor = color),
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          const Divider(),
                          const SizedBox(height: AppSpacing.md),
                          
                          Text('Faculty Details (Optional)', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _facultyNameController,
                            decoration: const InputDecoration(labelText: 'Faculty Name'),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _facultyEmailController,
                            decoration: const InputDecoration(labelText: 'Faculty Email'),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _facultyPhoneController,
                            decoration: const InputDecoration(labelText: 'Faculty Phone'),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          
                          const SizedBox(height: AppSpacing.xl),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                            maxLines: 3,
                            validator: SubjectValidator.validateNotes,
                            textInputAction: TextInputAction.done,
                          ),
                          
                          const SizedBox(height: AppSpacing.xxl),
                          FilledButton(
                            onPressed: _save,
                            child: const Text('Save Subject'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
}

/// Helper function to show the subject form as a bottom sheet
Future<void> showSubjectFormSheet(BuildContext context, {int? subjectId}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent, // Required to show container border radius
    builder: (context) => SubjectFormSheet(subjectId: subjectId),
  );
}
