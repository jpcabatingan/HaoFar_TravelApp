import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/api/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthApi _authService = FirebaseAuthApi();
  User? user;

  AuthProvider() {
    fetchUser();
  }

  void fetchUser() async {
    user = _authService.getUser();
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      fetchUser();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      fetchUser();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
  ) async {
    try {
      await _authService.signUp(email, password, username, firstName, lastName);
      fetchUser();
    } catch (e) {
      throw e.toString();
    }
  }
}
