import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/haptics.dart';
import '../../../database/collections/attendance_collection.dart';
import '../../../database/collections/subject_collection.dart';
import '../../../engines/attendance_engine.dart';
import '../../settings/providers/semester_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../subjects/providers/subject_providers.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/ads/interstitial_ad_manager.dart';

class BunkSimulatorScreen extends ConsumerStatefulWidget {
  const BunkSimulatorScreen({super.key});

  @override
  ConsumerState<BunkSimulatorScreen> createState() =>
      _BunkSimulatorScreenState();
}

class _BunkSimulatorScreenState extends ConsumerState<BunkSimulatorScreen> {
  int? _selectedSubjectId; // null means "Overall"
  double _futurePresent = 0;
  double _futureAbsent = 0;
  double _futureMedical = 0;
  double _futureGT = 0;

  void _resetSliders() {
    setState(() {
      _futurePresent = 0;
      _futureAbsent = 0;
      _futureMedical = 0;
      _futureGT = 0;
    });
    Haptics.heavy();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semester = ref.watch(semesterStateProvider);
    final settings = ref.watch(settingsProvider);

    if (semester == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Bunk Simulator',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Text('No active semester selected.',
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7))),
        ),
      );
    }

    final subjectsAsync = ref.watch(subjectsProvider);
    final attendanceAsync =
        ref.watch(attendanceRepositoryProvider).watchAll(semester.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            InterstitialAdManager.instance.showAdIfAvailable(
              feature: 'bunk_sim_exit',
              onNavigation: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
        title: Text(
          'Bunk & Predictor',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7)),
            tooltip: 'Reset Sim',
            onPressed: _resetSliders,
          ),
        ],
      ),
      body: subjectsAsync.when(
        data: (subjects) {
          final activeSubjects = subjects.where((s) => s.isActive).toList();

          return StreamBuilder<List<Attendance>>(
            stream: attendanceAsync,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final allAttendances = snapshot.data!;

              // Calculate current and simulated values
              double currentPresent = 0;
              double currentTotal = 0;
              double targetGoal = settings.defaultGoalPercentage;

              if (_selectedSubjectId == null) {
                // Overall Attendance Calculation
                final includedSubjectIds = activeSubjects
                    .where((s) => s.isIncludedInOverall)
                    .map((s) => s.id)
                    .toSet();
                final includedAttendances = allAttendances
                    .where((a) => includedSubjectIds.contains(a.subjectId))
                    .toList();

                final summary = AttendanceEngine.calculateOverallSummary(
                    includedAttendances, settings, semester);
                currentPresent = summary.effectivePresent.toDouble();
                currentTotal = summary.effectiveTotal.toDouble();
              } else {
                // Per-Subject Calculation
                final subject = activeSubjects
                    .firstWhere((s) => s.id == _selectedSubjectId);
                targetGoal = subject.goalPercentage;

                final summary = AttendanceEngine.calculateSubjectSummary(
                    subject.id, allAttendances, settings, semester);
                currentPresent = summary.effectivePresent.toDouble();
                currentTotal = summary.effectiveTotal.toDouble();
              }

              // Calculate Projected Values
              double projectedPresent = currentPresent + _futurePresent;
              double projectedTotal =
                  currentTotal + _futurePresent + _futureAbsent;

              // Medical count rule - always counts as Present
              projectedPresent += _futureMedical;
              projectedTotal += _futureMedical;

              // GT count rule - always excluded

              final currentPercentage =
                  currentTotal == 0 ? 0.0 : (currentPresent / currentTotal);
              final projectedPercentage = projectedTotal == 0
                  ? 0.0
                  : (projectedPresent / projectedTotal);

              final isSafe = (projectedPercentage * 100) >= targetGoal;
              final Color statusColor =
                  isSafe ? Colors.greenAccent : const Color(0xFFFF5F5F);

              return ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Dropdown Card
                  _buildSubjectSelectorCard(activeSubjects),
                  const SizedBox(height: 24),

                  // Projected Card
                  _buildProjectionCard(
                    currentPercentage: currentPercentage,
                    currentPresent: currentPresent.toInt(),
                    currentTotal: currentTotal.toInt(),
                    projectedPercentage: projectedPercentage,
                    projectedPresent: projectedPresent.toInt(),
                    projectedTotal: projectedTotal.toInt(),
                    targetGoal: targetGoal,
                    statusColor: statusColor,
                    isSafe: isSafe,
                  ),
                  const SizedBox(height: 32),

                  // Sliders Section
                  Text(
                    'SIMULATE FUTURE CLASSES',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSlider(
                    title: 'Attend (Present)',
                    value: _futurePresent,
                    max: 30,
                    icon: Icons.check_circle_outline_rounded,
                    activeColor: Colors.greenAccent,
                    onChanged: (val) {
                      setState(() => _futurePresent = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSlider(
                    title: 'Bunk (Absent)',
                    value: _futureAbsent,
                    max: 30,
                    icon: Icons.cancel_outlined,
                    activeColor: const Color(0xFFFF5F5F),
                    onChanged: (val) {
                      setState(() => _futureAbsent = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSlider(
                    title: 'Medical Leaves',
                    value: _futureMedical,
                    max: 30,
                    icon: Icons.local_hospital_outlined,
                    activeColor: Colors.orange,
                    subtitle: 'Counts as Present',
                    onChanged: (val) {
                      setState(() => _futureMedical = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildSlider(
                    title: 'GT / Duty Leaves',
                    value: _futureGT,
                    max: 30,
                    icon: Icons.stars_rounded,
                    activeColor: Colors.purpleAccent,
                    subtitle: 'Excluded from totals',
                    onChanged: (val) {
                      setState(() => _futureGT = val);
                    },
                  ),
                  const SizedBox(height: 24),
                  const BannerAdWidget(),
                  const SizedBox(height: 48),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ),
    );
  }

  Widget _buildSubjectSelectorCard(List<Subject> subjects) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedSubjectId,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          isExpanded: true,
          hint: Text('Overall Attendance',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.dashboard_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Text('Overall Attendance',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ...subjects.map((sub) {
              return DropdownMenuItem<int?>(
                value: sub.id,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(sub.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        sub.name,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (val) {
            setState(() {
              _selectedSubjectId = val;
            });
            Haptics.selection();
          },
        ),
      ),
    );
  }

  Widget _buildProjectionCard({
    required double currentPercentage,
    required int currentPresent,
    required int currentTotal,
    required double projectedPercentage,
    required int projectedPresent,
    required int projectedTotal,
    required double targetGoal,
    required Color statusColor,
    required bool isSafe,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSafe
              ? [
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                  Theme.of(context).colorScheme.surfaceContainer,
                ]
              : [
                  Theme.of(context).colorScheme.errorContainer,
                  Theme.of(context).colorScheme.surfaceContainer,
                ],
        ),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(currentPercentage * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$currentPresent/$currentTotal classes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TARGET GOAL',
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${targetGoal.toInt()}%',
                    style: TextStyle(
                        fontSize: 22,
                        color: statusColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          // Large projected ring and value
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: projectedPercentage,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  Text(
                    '${(projectedPercentage * 100).toInt()}%',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROJECTED ATTENDANCE',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$projectedPresent / $projectedTotal classes',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              isSafe
                                  ? Icons.check_circle_rounded
                                  : Icons.warning_amber_rounded,
                              color: statusColor,
                              size: 14),
                          const SizedBox(width: 6),
                          Text(
                            isSafe ? 'SAFE ZONE' : 'AT RISK',
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double max,
    required IconData icon,
    required Color activeColor,
    String? subtitle,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: activeColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                            fontSize: 11),
                      ),
                  ],
                ),
              ),
              Text(
                '+${value.toInt()}',
                style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.1),
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: max,
              divisions: max.toInt(),
              onChanged: (val) {
                onChanged(val);
                Haptics.selection();
              },
            ),
          ),
        ],
      ),
    );
  }
}
