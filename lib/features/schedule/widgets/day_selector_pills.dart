import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/enums/day_of_week.dart';
import '../../../core/utils/haptics.dart';

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
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                  Haptics.selection();
                  onDaySelected(index);
                }
              },
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
              selectedColor: const Color(0xFF7E73FF),
              backgroundColor: const Color(0xFF16162C),
              side: isSelected ? BorderSide.none : BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
