import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthApi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getUser() {
    return _auth.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    try {
      var credentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(credentials);
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> getEmail(String username) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();
      if (snapshot.docs.isNotEmpty) {
        String email = snapshot.docs[0]['email'];
        return {'status': true, 'email': email};
      } else {
        return {'status': false, 'error': 'Username not found'};
      }
    } catch (e) {
      return {'status': false, 'error': e.toString()};
    }
  }

  // Sign up with email/password
  Future<User?> signUp(
    String email,
    String password,
    String username,
    String firstName,
    String lastName,
  ) async {
    try {
      // Check if username is available
      QuerySnapshot usernameCheck =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();
      if (usernameCheck.docs.isNotEmpty) {
        throw 'Username already taken';
      }

      // Create Firebase Auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'email': email,
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
          'interests': [],
          'travelStyles': [],
          'isProfilePublic': true,
          'friends': [],
          'notificationPreference': 3,
        });
      }
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'interests': interests,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> updateTravelStyles(
    String userId,
    List<String> travelStyles,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'travelStyles': travelStyles,
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
