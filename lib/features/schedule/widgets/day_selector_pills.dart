import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/day_of_week.dart';

class DaySelectorPills extends StatelessWidget {
  final List<DayOfWeek> days;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;

  const DaySelectorPills({
    super.key,
    required this.days,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: List.generate(days.length, (index) {
          final isSelected = index == selectedDayIndex;
          final day = days[index];

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(day.shortLabel),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onDaySelected(index);
                }
              },
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        }),
      ),
    );
  }
}
