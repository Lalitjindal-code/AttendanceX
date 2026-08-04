import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

class SubjectColorPicker extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onColorSelected;

  const SubjectColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const List<int> defaultColors = [
    0xFF1565C0, // Blue
    0xFFC62828, // Red
    0xFF2E7D32, // Green
    0xFFEF6C00, // Orange
    0xFF6A1B9A, // Purple
    0xFF00838F, // Cyan
    0xFF4E342E, // Brown
    0xFF37474F, // Blue Grey
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: defaultColors.map((c) {
        final isSelected = c == selectedColor;
        return Semantics(
          label: 'Color option ${c.toRadixString(16)}',
          selected: isSelected,
          button: true,
          child: InkWell(
            onTap: () => onColorSelected(c),
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(c),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 3,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(c).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
