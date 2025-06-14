import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/api/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthApi _authService = FirebaseAuthApi();
  User? user;

  AuthProvider() {
    fetchUser();
  }

  Future<void> fetchUser() async {
    user = _authService.getUser();
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    fetchUser();
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      fetchUser();
      
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signInWithUsername(String username, String password) async {
    try {
      Map<String, dynamic> result = await _authService.getEmail(username);
      if (result['status'] == false) {
        throw result['error'];
      }
      String email = result['email'];

      await _authService.signIn(email, password);
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

  Future<void> checkAuthStatus() async {
    try {
      await Future.wait<void>([
        fetchUser(),
        Future.delayed(const Duration(seconds: 2)),
      ]);
    } catch (e) {
      user = null;
      notifyListeners();
    }
  }

  Future<void> updateInterests(List<String> interests) async {
    try {
      if (user == null) throw 'User not logged in';
      await _authService.updateInterests(user!.uid, interests);
      await fetchUser();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateTravelStyles(List<String> travelStyles) async {
    try {
      if (user == null) throw 'User not logged in';
      await _authService.updateTravelStyles(user!.uid, travelStyles);
      await fetchUser();
    } catch (e) {
      throw e.toString();
    }
  }
}
