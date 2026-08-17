import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/college_data.dart';
import '../../../scripts/import_aids_1st_sem.dart';
import '../../settings/providers/semester_provider.dart';
import '../../../navigation/app_routes.dart';
class CollegeZoneScreen extends ConsumerStatefulWidget {
  const CollegeZoneScreen({super.key});

  @override
  ConsumerState<CollegeZoneScreen> createState() => _CollegeZoneScreenState();
}

class _CollegeZoneScreenState extends ConsumerState<CollegeZoneScreen> {
  int? _selectedSemester;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Text(
          _selectedSemester == null ? 'Select Semester' : 'Select Branch',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold),
        ),
        leading: _selectedSemester != null
            ? IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => setState(() => _selectedSemester = null),
              )
            : IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
      ),
      body:
          _selectedSemester == null ? _buildSemesterList() : _buildBranchList(),
    );
  }

  Widget _buildSemesterList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: CollegeData.semesters.length,
      itemBuilder: (context, index) {
        final sem = CollegeData.semesters[index];
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            title: Text('Semester $sem',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.chevron_right,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.54)),
            onTap: () {
              setState(() {
                _selectedSemester = sem;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBranchList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: CollegeData.branches.length,
      itemBuilder: (context, index) {
        final branch = CollegeData.branches[index];
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            title: Text(
                (_selectedSemester == 1 && branch == 'AIADS') ? '$branch (Available)' : branch,
                style: TextStyle(
                    color: (_selectedSemester == 1 && branch == 'AIADS') 
                        ? Colors.green 
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            trailing: Icon(Icons.download_rounded,
                color: Theme.of(context).colorScheme.primary),
            onTap: () async {
              if (_selectedSemester == 1 && branch == 'AIADS') {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                
                // Ensure name and start date are set correctly
                await ref.read(semesterStateProvider.notifier).updateSemester(
                      'B.Tech AI&DS 1st Sem',
                      DateTime(2026, 8, 17),
                    );

                await ImportAids1stSem.run();
                
                if (mounted) {
                  Navigator.pop(context); // hide loading
                  context.go(AppRoutes.dashboard); // or show success toast
                }
              } else {
                _showComingSoonDialog(branch);
              }
            },
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(String branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Coming Soon!',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold)),
        content: Text(
          'Timetable for Semester $_selectedSemester - $branch is not uploaded yet. Check back later!',
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.push(AppRoutes.requestTimetable, extra: {
                'branch': branch,
                'semester': _selectedSemester.toString(),
              });
            },
            child: const Text('Upload Timetable',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
