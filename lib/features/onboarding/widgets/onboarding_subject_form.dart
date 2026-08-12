import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../database/collections/subject_collection.dart';
import '../../settings/providers/semester_provider.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../subjects/widgets/subject_color_picker.dart';

class OnboardingSubjectForm extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingSubjectForm({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingSubjectForm> createState() =>
      _OnboardingSubjectFormState();
}

class _OnboardingSubjectFormState extends ConsumerState<OnboardingSubjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _goalController = TextEditingController(text: '75.0');
  int _selectedColor = SubjectColorPicker.defaultColors[0];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final activeSemester = ref.read(semesterStateProvider);
      if (activeSemester == null) {
        throw Exception(
            'Active semester not initialized. Please go back and configure it.');
      }

      final subject = Subject()
        ..semesterId = activeSemester.id
        ..name = _nameController.text.trim()
        ..goalPercentage = double.parse(_goalController.text.trim())
        ..colorValue = _selectedColor
        ..credits = 3;

      await ref.read(subjectRepositoryProvider).create(subject);

      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Let's add your first subject",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'You can always add more later.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    hintText: 'e.g. Mathematics',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _goalController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Percentage (%)',
                    hintText: 'e.g. 75',
                    prefixIcon: Icon(Icons.track_changes),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a goal';
                    }
                    final parsed = double.tryParse(val);
                    if (parsed == null || parsed < 1 || parsed > 100) {
                      return 'Enter a valid percentage';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Color',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                SubjectColorPicker(
                  selectedColor: _selectedColor,
                  onColorSelected: (color) =>
                      setState(() => _selectedColor = color),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Get Started'),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: widget.onComplete,
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
