import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_icons.dart';
import '../../../navigation/app_routes.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(AppIcons.calendar),
            title: const Text('Calendar'),
            onTap: () => context.push(AppRoutes.calendar),
          ),
          ListTile(
            leading: const Icon(AppIcons.analytics),
            title: const Text('Analytics'),
            onTap: () => context.push(AppRoutes.analytics),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(AppIcons.settings),
            title: const Text('Settings'),
            onTap: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
    );
  }
}
