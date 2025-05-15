// api/user_api.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/user.dart'; // Ensure this path is correct

class UserApi {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Added for current user check

  // Get user document
  Future<UserModel> getUser(String userId) async {
    final DocumentSnapshot snapshot = await users.doc(userId).get();

    if (snapshot.exists) {
      // Ensure data is cast correctly, handle potential nulls if necessary
      return UserModel.fromFirestore(snapshot);
    } else {
      // This else block might be problematic if called for a user that truly doesn't exist
      // and isn't the current user. Consider if default data creation is always desired here.
      final User? currentUser = _auth.currentUser; // Nullable current user

      if (currentUser != null && userId == currentUser.uid) {
        // Create default user document only if it's for the currently authenticated user
        // and their document doesn't exist.
        final defaultData = {
          'userId': userId,
          'email': currentUser.email ?? '', // Provide default if null
          'username':
              currentUser.email?.split('@')[0] ??
              'traveler${DateTime.now().millisecondsSinceEpoch}', // More unique default
          'firstName': currentUser.displayName?.split(' ').first ?? 'User',
          // Corrected line for lastName:
          'lastName':
              (currentUser.displayName?.split(' ')?.length ?? 0) > 1
                  ? currentUser.displayName!.split(' ').last
                  : '',
          'phoneNumber': currentUser.phoneNumber ?? '',
          'interests': [],
          'travelStyles': [],
          'isProfilePublic': true,
          'createdAt': FieldValue.serverTimestamp(),
          'friends': [],
          'notificationPreference': 3,
          'profilePicture': null, // Explicitly null
          'bio': null, // Explicitly null
        };

        await users.doc(userId).set(defaultData);
        final newSnapshot = await users.doc(userId).get();
        return UserModel.fromFirestore(newSnapshot);
      } else {
        // If the userId doesn't match the current user or no user is logged in,
        // and the document doesn't exist, throw an error or return a specific state.
        throw Exception(
          'User document not found and cannot create default for this user.',
        );
      }
    }
  }

  // Get all user documents
  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await users.get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      // Log the error or handle it as per your app's error strategy
      print('Error fetching all users: $e');
      throw 'Failed to fetch users: $e';
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
      print('Error updating profile: $e');
      throw 'Failed to update profile: $e';
    }
  }

  // Update user interests
  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await users.doc(userId).update({'interests': interests});
    } catch (e) {
      print('Error updating interests: $e');
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
      print('Error updating travel styles: $e');
      throw 'Failed to update travel styles: $e';
    }
  }

  // Update profile picture
  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await users.doc(userId).update({'profilePicture': imageUrl});
    } catch (e) {
      print('Error updating profile picture: $e');
      throw 'Failed to update profile picture: $e';
    }
  }
}
