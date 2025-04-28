import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? phoneNumber;
  final List<String> interests;
  final List<String> travelStyles;
  final String? profilePicture;
  final bool isProfilePublic;
  final List<String> friends;
  final int notificationPreference;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.interests = const [],
    this.travelStyles = const [],
    this.profilePicture,
    this.isProfilePublic = true,
    this.friends = const [],
    this.notificationPreference = 3,
  });

  // Convert Firestore Document to User object
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      userId: data['userId'] ?? doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'],
      interests: List<String>.from(data['interests'] ?? []),
      travelStyles: List<String>.from(data['travelStyles'] ?? []),
      profilePicture: data['profilePicture'],
      isProfilePublic: data['isProfilePublic'] ?? true,
      friends: List<String>.from(data['friends'] ?? []),
      notificationPreference: data['notificationPreference'] ?? 3,
    );
  }

  // Convert User object to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'interests': interests,
      'travelStyles': travelStyles,
      'profilePicture': profilePicture,
      'isProfilePublic': isProfilePublic,
      'friends': friends,
      'notificationPreference': notificationPreference,
    };
  }
}
