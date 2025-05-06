// providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/api/users_api.dart';
import 'package:project/models/user.dart';

class UserProvider with ChangeNotifier {
  final UserApi _userApi = UserApi();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _user;

  UserProvider() {
    _init();
  }

  void _init() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      await fetchUser(userId);
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser(String userId) async {
    try {
      final userModel = await _userApi.getUser(userId);
      _user = userModel;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    try {
      await _userApi.updateProfile(userId, updateData);
      await fetchUser(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateInterests(List<String> interests) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    try {
      await _userApi.updateInterests(userId, interests);
      await fetchUser(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTravelStyles(List<String> travelStyles) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    try {
      await _userApi.updateTravelStyles(userId, travelStyles);
      await fetchUser(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not authenticated");

    try {
      await _userApi.updateProfilePicture(userId, imageUrl);
      await fetchUser(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
