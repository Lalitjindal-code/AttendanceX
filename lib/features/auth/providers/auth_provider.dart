import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _mockAuthStreamController = StreamController<User?>.broadcast();
User? _mockCurrentUser;

class MockUser implements User {
  @override
  final String? displayName;
  @override
  final String? email;
  @override
  final String? photoURL;
  @override
  final String uid;

  MockUser({
    this.displayName = 'Debug Student',
    this.email = 'student@example.com',
    this.photoURL,
    this.uid = 'debug_uid_123',
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  @override
  final User user;

  MockUserCredential(this.user);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Provides the global instance of FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  if (!kIsWeb && Platform.isWindows) {
    throw UnsupportedError(
        'FirebaseAuth is not supported on Windows. Use authProvider instead.');
  }
  return FirebaseAuth.instance;
});

// A stream provider that emits the current user whenever the auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  if (!kIsWeb && Platform.isWindows) {
    final controller = StreamController<User?>();
    controller.add(_mockCurrentUser);
    final sub =
        _mockAuthStreamController.stream.listen((u) => controller.add(u));
    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });
    return controller.stream;
  }
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Provider to handle authentication logic
final authProvider = Provider<AuthService>((ref) {
  final auth =
      (!kIsWeb && Platform.isWindows) ? null : ref.watch(firebaseAuthProvider);
  return AuthService(auth);
});

class AuthService {
  final FirebaseAuth? _auth;

  AuthService(this._auth);

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    if (!kIsWeb && Platform.isWindows) {
      _mockCurrentUser = MockUser(
        displayName: email.split('@')[0],
        email: email,
      );
      _mockAuthStreamController.add(_mockCurrentUser);
      return MockUserCredential(_mockCurrentUser!);
    }
    return await _auth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    if (!kIsWeb && Platform.isWindows) {
      _mockCurrentUser = MockUser(
        displayName: email.split('@')[0],
        email: email,
      );
      _mockAuthStreamController.add(_mockCurrentUser);
      return MockUserCredential(_mockCurrentUser!);
    }
    return await _auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    if (!kIsWeb && Platform.isWindows) {
      _mockCurrentUser = null;
      _mockAuthStreamController.add(null);
      return;
    }
    await _auth!.signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (!kIsWeb && Platform.isWindows) {
      _mockCurrentUser = MockUser(
        displayName: 'Google Student',
        email: 'google@example.com',
      );
      _mockAuthStreamController.add(_mockCurrentUser);
      return MockUserCredential(_mockCurrentUser!);
    }
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null; // The user canceled the sign-in
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await _auth!.signInWithCredential(credential);
  }
}
