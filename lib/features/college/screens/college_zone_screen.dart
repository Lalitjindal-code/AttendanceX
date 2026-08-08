import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/college_data.dart';

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
      backgroundColor: const Color(0xFF0B0B13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B13),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _selectedSemester == null ? 'Select Semester' : 'Select Branch',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: _selectedSemester != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedSemester = null),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
      ),
      body: _selectedSemester == null ? _buildSemesterList() : _buildBranchList(),
    );
  }

  Widget _buildSemesterList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: CollegeData.semesters.length,
      itemBuilder: (context, index) {
        final sem = CollegeData.semesters[index];
        return Card(
          color: const Color(0xFF1E1E2C),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            title: Text('Semester $sem', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
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
          color: const Color(0xFF1E1E2C),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            title: Text(branch, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.download_rounded, color: Color(0xFF7E73FF)),
            onTap: () {
              _showComingSoonDialog(branch);
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
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Coming Soon!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Timetable for Semester $_selectedSemester - $branch is not uploaded yet. Check back later!',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay', style: TextStyle(color: Color(0xFF7E73FF), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
