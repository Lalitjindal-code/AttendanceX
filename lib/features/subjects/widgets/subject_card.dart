import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../navigation/app_routes.dart';
import '../../dashboard/models/attendance_summary.dart';
import '../providers/subject_providers.dart';

class SubjectCard extends ConsumerWidget {
  final Subject subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(subjectSummaryProvider(subject.id));

    return Semantics(
      label: '${subject.name} Subject. ${subject.credits} Credits. Goal: ${subject.goalPercentage.toInt()}%.',
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.subjects}/detail/${subject.id}');
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Color Stripe with Hero
              Hero(
                tag: 'subject_color_${subject.id}',
                child: Container(
                  width: 12,
                  color: Color(subject.colorValue),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${subject.credits} Credits • Goal: ${subject.goalPercentage.toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.md),
                      summaryAsync.when(
                        data: (summary) => _buildProgress(context, summary),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProgress(BuildContext context, SubjectAttendanceSummary summary) {
    final percent = summary.attendancePercentage;
    final isSafe = percent >= subject.goalPercentage;
    
    final progressColor = isSafe 
        ? Theme.of(context).colorScheme.primary 
        : Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
            ),
            Text(
              '${summary.effectivePresent}/${summary.effectiveTotal}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: summary.effectiveTotal == 0 ? 0.0 : summary.effectivePresent / summary.effectiveTotal,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          color: progressColor,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
