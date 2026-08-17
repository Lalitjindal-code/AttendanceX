import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_spacing.dart';
import '../../settings/providers/settings_provider.dart';

class OnboardingProfileForm extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingProfileForm({super.key, required this.onComplete});

  @override
  ConsumerState<OnboardingProfileForm> createState() =>
      _OnboardingProfileFormState();
}

class _OnboardingProfileFormState extends ConsumerState<OnboardingProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedBranch;
  String? _selectedSemester;
  
  bool _isLoading = false;

  final List<String> _branches = [
    'CSE',
    'IT',
    'ECE',
    'AI & DS',
    'Mechanical',
    'Civil',
    'Electrical',
    'Other'
  ];

  final List<String> _semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranch == null || _selectedSemester == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select branch and semester')));
       return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(settingsProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        branch: _selectedBranch,
        currentSemester: _selectedSemester,
      );

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
                  "Set up your Profile",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tell us a little bit about yourself.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. John Doe',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Branch',
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  value: _selectedBranch,
                  items: _branches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedBranch = val);
                  },
                  validator: (val) => val == null ? 'Please select a branch' : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Semester',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  value: _selectedSemester,
                  items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedSemester = val);
                  },
                  validator: (val) => val == null ? 'Please select a semester' : null,
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
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
