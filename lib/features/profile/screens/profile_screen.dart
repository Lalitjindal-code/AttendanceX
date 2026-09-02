import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../college/data/college_data.dart';
import '../providers/active_profile_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../backup/providers/backup_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentName, String? currentBranch, String? currentSemester) {
    final nameController = TextEditingController(text: currentName);
    String? selectedBranch = currentBranch;
    String? selectedSemester = currentSemester;
    
    final branches = CollegeData.branches.toList();
    final semesters = ['1st Semester', '2nd Semester', '3rd Semester', '4th Semester', '5th Semester', '6th Semester', '7th Semester', '8th Semester', 'Other'];

    if (selectedBranch != null && !branches.contains(selectedBranch)) branches.add(selectedBranch);
    if (selectedSemester != null && !semesters.contains(selectedSemester)) semesters.add(selectedSemester);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Branch'),
                      value: selectedBranch,
                      isExpanded: true,
                      items: branches.map((b) => DropdownMenuItem(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setState(() => selectedBranch = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Semester'),
                      value: selectedSemester,
                      isExpanded: true,
                      items: semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) => setState(() => selectedSemester = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).updateProfile(
                      name: nameController.text.trim(),
                      branch: selectedBranch,
                      currentSemester: selectedSemester,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = ref.watch(activeProfileStreamProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              final profile = profileAsync.valueOrNull;
              _showEditProfileDialog(context, ref, profile?.name ?? user.displayName ?? '', profile?.branch, profile?.currentSemester);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(backupControllerProvider.notifier).createAutoBackup();
              await ref.read(authProvider).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            profileAsync.when(
              data: (profile) => Column(
                children: [
                  Text(
                    profile.name.isNotEmpty ? profile.name : (user.displayName ?? 'Student'),
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ?? '',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  
                  // Academic Details Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.school_outlined),
                          title: const Text('Branch'),
                          subtitle: Text(profile.branch?.isNotEmpty == true ? profile.branch! : 'Not set'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.menu_book_outlined),
                          title: const Text('Semester'),
                          subtitle: Text(profile.currentSemester?.isNotEmpty == true ? profile.currentSemester! : 'Not set'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.track_changes_outlined),
                          title: const Text('Attendance Goal'),
                          subtitle: Text('${profile.defaultGoalPercentage.toStringAsFixed(0)}%'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Account Details Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: const Text('Account ID'),
                          subtitle: Text(user.uid),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.verified_user_outlined),
                          title: const Text('Status'),
                          subtitle: const Text('Active & Verified'),
                          trailing: Icon(Icons.check_circle,
                              color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error loading profile: $err'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(backupControllerProvider.notifier).createAutoBackup();
                  await ref.read(authProvider).signOut();
                },
                icon: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.error),
                label: Text('Sign Out',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
