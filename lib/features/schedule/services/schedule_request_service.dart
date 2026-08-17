import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scheduleRequestServiceProvider = Provider((ref) => ScheduleRequestService());

final userScheduleRequestsProvider = StreamProvider<QuerySnapshot<Map<String, dynamic>>>((ref) {
  return ref.watch(scheduleRequestServiceProvider).watchUserScheduleRequests();
});

class ScheduleRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloudinary Config
  static const String _cloudName = 'ygcexv3a';
  static const String _uploadPreset = 'attendify_preset';

  /// Checks if a global schedule exists for the given branch and semester.
  Future<bool> checkScheduleAvailability(String branch, String semester) async {
    try {
      final docId = '${branch}_$semester'.replaceAll(' ', '_');
      final doc = await _firestore.collection('global_schedules').doc(docId).get();
      return doc.exists;
    } catch (e) {
      return false; // Fail safe
    }
  }

  /// Submits a request for a timetable with an uploaded image.
  Future<void> requestTimetable(String branch, String semester, File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload image to Cloudinary
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
        
      final response = await request.send();
      
      if (response.statusCode != 200) {
        throw Exception('Failed to upload image to Cloudinary');
      }
      
      final responseData = await response.stream.bytesToString();
      final jsonData = jsonDecode(responseData);
      final downloadUrl = jsonData['secure_url'];

      if (downloadUrl == null) {
        throw Exception('Failed to get secure URL from Cloudinary');
      }

      // Create an individual request document
      await _firestore.collection('schedule_requests').add({
        'userId': user.uid,
        'userEmail': user.email ?? 'Unknown',
        'branch': branch,
        'semester': semester,
        'imageUrl': downloadUrl,
        'status': 'pending', // 'pending', 'approved', 'rejected'
        'adminMessage': '',
        'userMessage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to request timetable: $e');
    }
  }

  /// Gets all schedule requests for Admin view.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllScheduleRequests() {
    return _firestore
        .collection('schedule_requests')
        .snapshots();
  }

  /// Gets schedule requests for the current user.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserScheduleRequests() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    
    return _firestore
        .collection('schedule_requests')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  /// Update request status (Admin)
  Future<void> updateRequestStatus(String docId, String status, String adminMessage) async {
    await _firestore.collection('schedule_requests').doc(docId).update({
      'status': status,
      'adminMessage': adminMessage,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update user message (User) - Legacy
  Future<void> updateUserMessage(String docId, String userMessage) async {
    await _firestore.collection('schedule_requests').doc(docId).update({
      'userMessage': userMessage,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send a chat message (Admin or User)
  Future<void> sendChatMessage(String docId, String sender, String text) async {
    final message = {
      'sender': sender,
      'text': text,
      'timestamp': Timestamp.now(),
    };
    await _firestore.collection('schedule_requests').doc(docId).update({
      'messages': FieldValue.arrayUnion([message]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Close the chat session (Admin only)
  Future<void> closeChatSession(String docId) async {
    await _firestore.collection('schedule_requests').doc(docId).update({
      'isChatClosed': true,
      'status': 'resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
