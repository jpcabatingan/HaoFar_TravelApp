// providers/user_provider.dart

import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';

class UserProvider with ChangeNotifier {
  final UserApi _userApi = UserApi();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>?
  _authStateSubscription; // To manage the subscription

  UserModel? _user;
  bool _isLoading = false; // Start with false, set to true when fetching
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _isLoading = true; // Initially, we might be loading auth state
    notifyListeners();

    _authStateSubscription = _auth.authStateChanges().listen(
      (User? firebaseUser) {
        if (firebaseUser == null) {
          // User logged out
          _user = null;
          _isLoading = false;
          _error = null;
          notifyListeners();
        } else {
          // User logged in or auth state changed with a user
          // Set loading true before fetching new user data
          _isLoading = true;
          _error = null; // Clear previous errors
          notifyListeners();
          fetchUser(firebaseUser.uid);
        }
      },
      onError: (e) {
        // Handle errors from the auth stream itself
        _user = null;
        _isLoading = false;
        _error = "Auth listener error: ${e.toString()}";
        notifyListeners();
      },
    );
  }

  Future<void> fetchUser(String userId) async {
    // This check prevents re-fetching if already loading for this user,
    // though _isLoading being set before calling fetchUser handles most cases.
    // if (_isLoading && _user?.userId == userId) return;

    _isLoading = true;
    // No need to notifyListeners here if it was already done in _listenToAuthChanges
    // or if the caller expects to handle UI updates. However, for direct calls, it might be useful.
    // For consistency with _listenToAuthChanges, let's assume the listener handles the initial loading notification.

    try {
      final userModel = await _userApi.getUser(userId);
      _user = userModel;
      _isLoading = false;
      _error = null;
    } catch (e) {
      _user = null; // Clear user data on error
      _error = "Failed to fetch user: ${e.toString()}";
      _isLoading = false;
    }
    notifyListeners(); // Notify after fetching is complete (success or failure)
  }

  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      _error = "User not authenticated for profile update.";
      notifyListeners();
      throw Exception("User not authenticated");
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _userApi.updateProfile(currentUserId, updateData);
      await fetchUser(currentUserId); // Re-fetch user data to reflect updates
    } catch (e) {
      _error = "Failed to update profile: ${e.toString()}";
      _isLoading = false; // Ensure loading is false on error
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateInterests(List<String> interests) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      _error = "User not authenticated for updating interests.";
      notifyListeners();
      throw Exception("User not authenticated");
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _userApi.updateInterests(currentUserId, interests);
      await fetchUser(currentUserId);
    } catch (e) {
      _error = "Failed to update interests: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTravelStyles(List<String> travelStyles) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      _error = "User not authenticated for updating travel styles.";
      notifyListeners();
      throw Exception("User not authenticated");
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _userApi.updateTravelStyles(currentUserId, travelStyles);
      await fetchUser(currentUserId);
    } catch (e) {
      _error = "Failed to update travel styles: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      _error = "User not authenticated for updating profile picture.";
      notifyListeners();
      throw Exception("User not authenticated");
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _userApi.updateProfilePicture(currentUserId, imageUrl);
      await fetchUser(currentUserId);
    } catch (e) {
      _error = "Failed to update profile picture: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription
        ?.cancel(); // Cancel subscription when provider is disposed
    super.dispose();
  }
}
