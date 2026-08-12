import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_spacing.dart';
import '../../settings/providers/semester_provider.dart';
import '../../college/providers/college_auth_provider.dart';
import '../../college/data/college_data.dart';

class OnboardingSemesterForm extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingSemesterForm({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingSemesterForm> createState() =>
      _OnboardingSemesterFormState();
}

class _OnboardingSemesterFormState
    extends ConsumerState<OnboardingSemesterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Semester 1');
  DateTime? _selectedDate;
  final _dateFormatter = DateFormat('MMMM d, yyyy');
  bool _isLoading = false;
  int _selectedSemester = 1;
  String _selectedBranch = CollegeData.branches.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).colorScheme.surfaceContainerHigh,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final isCollegeUser = ref.read(isCollegeUserProvider);
      final name = isCollegeUser
          ? 'Semester $_selectedSemester - $_selectedBranch'
          : _nameController.text.trim();
      await ref
          .read(semesterStateProvider.notifier)
          .updateSemester(name, _selectedDate ?? DateTime.now());

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
    final theme = Theme.of(context);

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
                  'Set up your semester',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Specify your current semester name and when it started.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (ref.watch(isCollegeUserProvider)) ...[
                  DropdownButtonFormField<int>(
                    initialValue: _selectedSemester,
                    decoration: const InputDecoration(
                        labelText: 'Semester',
                        prefixIcon: Icon(Icons.school_outlined)),
                    items: CollegeData.semesters
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text('Semester $s')))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSemester = val!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBranch,
                    decoration: const InputDecoration(
                        labelText: 'Branch',
                        prefixIcon: Icon(Icons.class_outlined)),
                    items: CollegeData.branches
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedBranch = val!),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Semester Name',
                      hintText: 'e.g. Semester 1',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date (Optional)',
                      prefixIcon: Icon(Icons.date_range_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Not set'
                              : _dateFormatter.format(_selectedDate!),
                          style: theme.textTheme.bodyLarge,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Next',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
