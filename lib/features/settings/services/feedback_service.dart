import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final feedbackServiceProvider = Provider((ref) => FeedbackService());

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cloudinary Config
  static const String _cloudName = 'ygcexv3a';
  static const String _uploadPreset = 'attendify_preset';

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['secure_url'] as String?;
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<void> submitFeedback({
    required String name,
    required String email,
    required String message,
    File? imageFile,
  }) async {
    String? imageUrl;
    
    if (imageFile != null) {
      imageUrl = await uploadImageToCloudinary(imageFile);
    }

    final user = _auth.currentUser;

    await _firestore.collection('feedbacks').add({
      'name': name,
      'email': email.isNotEmpty ? email : 'No Email Provided',
      'message': message,
      'imageUrl': imageUrl,
      'userId': user?.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'new', // For admin panel tracking
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllFeedbacks() {
    return _firestore
        .collection('feedbacks')
        .snapshots(); // orderBy requires index, will sort locally instead
  }
}
