import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.subjectsTitle)),
      body: const Center(child: Text('Subjects Screen Placeholder')),
    );
  }
}
