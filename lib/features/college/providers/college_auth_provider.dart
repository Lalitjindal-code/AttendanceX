import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

final isCollegeUserProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  
  // SATI Zone is now accessible to all authenticated users, regardless of domain.
  return true;
});
