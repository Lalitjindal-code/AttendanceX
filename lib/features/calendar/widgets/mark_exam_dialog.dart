import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/exam_type.dart';

/// Modal dialog for choosing an [ExamType] when marking an entire day or slot as an Exam.
class MarkExamDialog extends StatefulWidget {
  final DateTime date;
  final ExamType? initialExamType;

  const MarkExamDialog({
    super.key,
    required this.date,
    this.initialExamType,
  });

  static Future<ExamType?> show(
    BuildContext context, {
    required DateTime date,
    ExamType? initialExamType,
  }) {
    return showDialog<ExamType>(
      context: context,
      builder: (context) => MarkExamDialog(
        date: date,
        initialExamType: initialExamType,
      ),
    );
  }

  @override
  State<MarkExamDialog> createState() => _MarkExamDialogState();
}

class _MarkExamDialogState extends State<MarkExamDialog> {
  late ExamType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialExamType ?? ExamType.midSem1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.assignment_rounded,
              color: Colors.amber.shade900,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('Mark Exam Day'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the type of exam. Attendance on exam days will be excluded from calculation.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...ExamType.values.map((type) {
            final isSelected = _selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<ExamType>(
                          value: type,
                          groupValue: _selectedType,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedType = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          type.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context, _selectedType),
          child: const Text('Confirm Exam'),
        ),
      ],
    );
  }
}
