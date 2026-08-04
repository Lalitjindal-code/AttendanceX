import 'dart:io';

void main() {
  final loginScreen = File('lib/features/auth/screens/login_screen.dart');
  var loginContent = loginScreen.readAsStringSync();
  loginContent = loginContent.replaceAll('AppSpacing.radiusMd', 'AppRadius.md');
  loginScreen.writeAsStringSync(loginContent);

  final signupScreen = File('lib/features/auth/screens/signup_screen.dart');
  var signupContent = signupScreen.readAsStringSync();
  signupContent = signupContent.replaceAll('AppSpacing.radiusMd', 'AppRadius.md');
  signupScreen.writeAsStringSync(signupContent);
}
