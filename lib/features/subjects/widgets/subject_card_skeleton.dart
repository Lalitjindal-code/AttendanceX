import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubjectCardSkeleton extends StatelessWidget {
  const SubjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF16162C),
      highlightColor: const Color(0xFF7E73FF).withValues(alpha: 0.1),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF16162C),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
