import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../database/collections/subject_collection.dart';
import '../../dashboard/models/attendance_summary.dart';
import '../providers/subject_providers.dart';
import 'subject_form_screen.dart';

class SubjectDetailScreen extends ConsumerWidget {
  final int subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(subjectProvider(subjectId));
    final summaryAsync = ref.watch(subjectSummaryProvider(subjectId));

    return Scaffold(
      body: subjectAsync.when(
        data: (subject) {
          if (subject == null) {
            return _buildError(context, 'Subject not found');
          }
          return _buildContent(context, subject, summaryAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    Subject subject, 
    AsyncValue<SubjectAttendanceSummary> summaryAsync,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(subject.name),
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Subject',
              onPressed: () => showSubjectFormSheet(context, subjectId: subject.id),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'subject_color_${subject.id}',
              child: Container(color: Color(subject.colorValue)),
            ),
            titlePadding: const EdgeInsets.only(left: 72, bottom: 16, right: 16),
            title: Text(
              subject.name,
              style: TextStyle(
                color: ThemeData.estimateBrightnessForColor(Color(subject.colorValue)) == Brightness.light 
                    ? Colors.black 
                    : Colors.white,
              ),
            ),
          ),
          iconTheme: IconThemeData(
            color: ThemeData.estimateBrightnessForColor(Color(subject.colorValue)) == Brightness.light 
                ? Colors.black 
                : Colors.white,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // General info
              _buildInfoRow(context, Icons.info_outline, '${subject.credits} Credits • Goal: ${subject.goalPercentage.toInt()}%'),
              if (subject.facultyName != null && subject.facultyName!.isNotEmpty)
                _buildInfoRow(context, Icons.person_outline, subject.facultyName!),
              if (subject.notes != null && subject.notes!.isNotEmpty)
                _buildInfoRow(context, Icons.notes, subject.notes!),
              
              const SizedBox(height: AppSpacing.xl),
              Text('Attendance Status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              
              summaryAsync.when(
                data: (summary) => _buildBunkCalculator(context, subject, summary),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error loading stats: $error'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBunkCalculator(BuildContext context, Subject subject, SubjectAttendanceSummary summary) {
    final currentPercentage = summary.attendancePercentage;
    final total = summary.effectiveTotal;
    final present = summary.effectivePresent;
    final target = subject.goalPercentage / 100.0;

    int safeToBunk = 0;
    int classesNeeded = 0;

    if (currentPercentage >= subject.goalPercentage) {
      // Calculate how many we can bunk before dropping below target
      // (present) / (total + x) >= target
      // present >= target * total + target * x
      // present - target * total >= target * x
      // x <= (present - target * total) / target
      if (target > 0) {
        final x = (present - (target * total)) / target;
        safeToBunk = x.floor();
      }
    } else {
      // Calculate how many consecutive present classes needed to reach target
      // (present + x) / (total + x) >= target
      // present + x >= target * total + target * x
      // x - target * x >= target * total - present
      // x * (1 - target) >= target * total - present
      // x >= (target * total - present) / (1 - target)
      if (target < 1.0) {
        final x = ((target * total) - present) / (1 - target);
        classesNeeded = x.ceil();
      } else {
        // If target is 100% and we are below, we can never reach it
        classesNeeded = -1;
      }
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              '${currentPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: currentPercentage >= subject.goalPercentage 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.error,
                  ),
            ),
            Text(
              '$present out of $total classes attended',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            if (currentPercentage >= subject.goalPercentage) ...[
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 32),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You are in the safe zone.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                safeToBunk > 0 
                    ? 'You can miss the next $safeToBunk classes and stay above ${subject.goalPercentage.toInt()}%.' 
                    : 'You cannot miss the next class without dropping below goal.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ] else ...[
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You are falling behind.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                classesNeeded > 0 
                    ? 'You need to attend the next $classesNeeded classes to reach ${subject.goalPercentage.toInt()}%.' 
                    : 'You cannot mathematically reach 100% anymore.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
