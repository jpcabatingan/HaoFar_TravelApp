// providers/user_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';

class UserProvider with ChangeNotifier {
  final UserApi _userApi = UserApi();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _isLoading = true;
    notifyListeners();

    _authStateSubscription = _auth.authStateChanges().listen(
      (User? firebaseUser) {
        if (firebaseUser == null) {
          _user = null;
          _isLoading = false;
          _error = null;
          notifyListeners();
        } else {
          _isLoading = true;
          _error = null;
          notifyListeners();
          fetchUser(firebaseUser.uid);
        }
      },
      onError: (e) {
        _user = null;
        _isLoading = false;
        _error = "Auth listener error: ${e.toString()}";
        notifyListeners();
      },
    );
  }

  Future<void> fetchUser(String userId) async {
    _isLoading = true;

    try {
      final userModel = await _userApi.getUser(userId);
      _user = userModel;
      _isLoading = false;
      _error = null;
    } catch (e) {
      _user = null;
      _error = "Failed to fetch user: ${e.toString()}";
      _isLoading = false;
    }
    notifyListeners();
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
      await fetchUser(currentUserId);
    } catch (e) {
      _error = "Failed to update profile: ${e.toString()}";
      _isLoading = false;
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
    _authStateSubscription?.cancel();
    super.dispose();
  }
}