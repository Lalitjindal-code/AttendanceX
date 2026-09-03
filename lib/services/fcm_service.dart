import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:attendify/core/providers/firebase_provider.dart';

final fcmServiceProvider = Provider<FCMService?>((ref) {
  if (kIsWeb || Platform.isWindows) {
    return null; // FCM is not supported on Windows, and we don't need it on web for this specific admin feature currently.
  }
  
  final isInit = ref.watch(firebaseInitProvider).hasValue;
  if (!isInit) return null;

  return FCMService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseMessaging.instance,
  );
});

final fcmTokenOrchestratorProvider = Provider<void>((ref) {
  final service = ref.watch(fcmServiceProvider);
  if (service != null) {
    service.startListening();
  }
});

class FCMService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  bool _isListening = false;

  FCMService(this._auth, this._firestore, this._messaging);

  void startListening() {
    if (_isListening) return;
    _isListening = true;

    // Listen to authentication state changes
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _setupFCM(user.uid);
      }
    });
  }

  Future<void> _setupFCM(String uid) async {
    try {
      // Request permission (Required for iOS)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get the initial token
        String? token = await _messaging.getToken();
        if (token != null) {
          await _saveTokenToFirestore(uid, token);
        }

        // Listen for token refreshes
        _messaging.onTokenRefresh.listen((newToken) {
          _saveTokenToFirestore(uid, newToken);
        });
      }
    } catch (e) {
      debugPrint('Error setting up FCM: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String uid, String token) async {
    try {
      await _firestore.collection('fcm_tokens').doc(uid).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}
