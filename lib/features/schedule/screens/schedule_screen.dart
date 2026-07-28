import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.scheduleTitle)),
      body: const Center(child: Text('Schedule Screen Placeholder')),
    );
  }
}
