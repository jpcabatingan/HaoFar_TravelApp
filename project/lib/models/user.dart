import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? phoneNumber;
  final String? bio;
  final List<String> interests;
  final List<String> travelStyles;
  final String? profilePicture;
  final bool isProfilePublic;
  final List<String> friends;
  final int notificationPreference;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.phoneNumber,
    this.bio,
    this.interests = const [],
    this.travelStyles = const [],
    this.profilePicture,
    this.isProfilePublic = true,
    this.friends = const [],
    this.notificationPreference = 3,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['userId'] ?? doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'],
      bio: data['bio'],
      interests: List<String>.from(data['interests'] ?? []),
      travelStyles: List<String>.from(data['travelStyles'] ?? []),
      profilePicture: data['profilePicture'],
      isProfilePublic: data['isProfilePublic'] ?? true,
      friends: List<String>.from(data['friends'] ?? []),
      notificationPreference: data['notificationPreference'] ?? 3,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'interests': interests,
      'travelStyles': travelStyles,
      'profilePicture': profilePicture,
      'isProfilePublic': isProfilePublic,
      'friends': friends,
      'notificationPreference': notificationPreference,
    };
  }
}
