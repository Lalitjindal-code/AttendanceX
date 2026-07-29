import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/subject_validator.dart';
import '../providers/subject_providers.dart';

class SubjectFormScreen extends ConsumerStatefulWidget {
  final int? subjectId;

  const SubjectFormScreen({super.key, this.subjectId});

  @override
  ConsumerState<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends ConsumerState<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _facultyNameController = TextEditingController();
  final _facultyEmailController = TextEditingController();
  final _facultyPhoneController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  final _goalController = TextEditingController(text: '75.0');
  final _notesController = TextEditingController();
  int _selectedColor = 0xFF1565C0;

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
      setState(() => _isLoading = false);
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
      if (mounted) context.pop();
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
            '• ${impact.schedulesCount} schedule entries\n'
            '• ${impact.attendancesCount} attendance records\n'
            '• ${impact.historyCount} attendance history records\n\n'
            'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => context.pop(true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await repo.deletePermanently(widget.subjectId!);
      if (mounted) {
        context.pop(); // Pop form screen
      }
    }
  }

  Widget _buildColorPicker() {
    // Simple predefined colors for Phase 2
    final colors = [
      0xFF1565C0, 0xFFC62828, 0xFF2E7D32, 0xFFEF6C00, 
      0xFF6A1B9A, 0xFF00838F, 0xFF4E342E, 0xFF37474F
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: colors.map((c) {
        final isSelected = c == _selectedColor;
        return InkWell(
          onTap: () => setState(() => _selectedColor = c),
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(c),
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subjectId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: _delete,
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Subject Name *', hintText: 'e.g. Data Structures'),
                      validator: SubjectValidator.validateName,
                      textCapitalization: TextCapitalization.words,
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
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: TextFormField(
                            controller: _goalController,
                            decoration: const InputDecoration(labelText: 'Goal % *'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: SubjectValidator.validateGoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    const Text('Subject Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    _buildColorPicker(),
                    
                    const SizedBox(height: AppSpacing.xl),
                    const Text('Faculty Details (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _facultyNameController,
                      decoration: const InputDecoration(labelText: 'Faculty Name'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _facultyEmailController,
                      decoration: const InputDecoration(labelText: 'Faculty Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _facultyPhoneController,
                      decoration: const InputDecoration(labelText: 'Faculty Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                      maxLines: 3,
                      validator: SubjectValidator.validateNotes,
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton(
                      onPressed: _save,
                      child: const Text('Save Subject'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }
}
