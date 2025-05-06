// api/user_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/user.dart';

class UserApi {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  // Get user document
  Future<UserModel> getUser(String userId) async {
    final DocumentSnapshot snapshot = await users.doc(userId).get();

    if (snapshot.exists) {
      return UserModel.fromFirestore(snapshot as DocumentSnapshot);
    } else {
      // Create default user document if it doesn't exist
      final User currentUser = FirebaseAuth.instance.currentUser!;

      final defaultData = {
        'userId': userId,
        'email': currentUser.email,
        'username': currentUser.email?.split('@')[0] ?? 'traveler',
        'firstName': currentUser.displayName?.split(' ').first ?? 'John',
        'lastName': currentUser.displayName?.split(' ').last ?? 'Doe',
        'phoneNumber': currentUser.phoneNumber ?? '',
        'interests': [],
        'travelStyles': [],
        'isProfilePublic': true,
        'createdAt': FieldValue.serverTimestamp(),
        'friends': [],
        'notificationPreference': 3,
      };

      await users.doc(userId).set(defaultData);
      return UserModel.fromFirestore(
        await users.doc(userId).get() as DocumentSnapshot,
      );
    }
  }

  // Update user profile
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      await users.doc(userId).update(updateData);
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  // Update user interests
  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await users.doc(userId).update({'interests': interests});
    } catch (e) {
      throw 'Failed to update interests: $e';
    }
  }

  // Update user travel styles
  Future<void> updateTravelStyles(
    String userId,
    List<String> travelStyles,
  ) async {
    try {
      await users.doc(userId).update({'travelStyles': travelStyles});
    } catch (e) {
      throw 'Failed to update travel styles: $e';
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await users.doc(userId).update({'profilePicture': imageUrl});
    } catch (e) {
      throw 'Failed to update profile picture: $e';
    }
  }
}
