import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analyticsTitle)),
      body: const Center(child: Text('Analytics Screen Placeholder')),
    );
  }
}
