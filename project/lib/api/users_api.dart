import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/user.dart';
import 'package:project/models/friend_request.dart';

class UserApi {
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );
  final CollectionReference friendRequests = FirebaseFirestore.instance
      .collection('friendRequests');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> getUser(String userId) async {
    final DocumentSnapshot snapshot = await users.doc(userId).get();

    if (snapshot.exists) {
      return UserModel.fromFirestore(snapshot);
    } else {
      // This logic is for creating a default user profile if it doesn't exist
      // upon first fetch for the currently authenticated user.
      final User? currentUserAuth = _auth.currentUser;
      if (currentUserAuth != null && userId == currentUserAuth.uid) {
        final defaultData = {
          'userId': userId,
          'email': currentUserAuth.email ?? '',
          'username':
              currentUserAuth.email?.split('@')[0] ??
              'traveler${DateTime.now().millisecondsSinceEpoch}',
          'firstName': currentUserAuth.displayName?.split(' ').first ?? 'User',
          'lastName':
              (currentUserAuth.displayName?.split(' ').length ?? 0) > 1
                  ? currentUserAuth.displayName!.split(' ').last
                  : '',
          'phoneNumber': currentUserAuth.phoneNumber ?? '',
          'interests': [],
          'travelStyles': [],
          'isProfilePublic': true, // Default to public, user can change
          'createdAt': FieldValue.serverTimestamp(),
          'friends': [],
          'notificationPreference': 3, // Default reminder gap
          'profilePicture': null,
          'bio': null,
        };
        await users.doc(userId).set(defaultData);
        final newSnapshot = await users.doc(userId).get();
        return UserModel.fromFirestore(newSnapshot);
      } else {
        // If trying to get a non-existent user who is not the current user.
        throw Exception('User document not found for ID: $userId');
      }
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await users.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final bool isPublic =
            data['isProfilePublic'] ?? true; // Default to true if missing

        if (isPublic) {
          return UserModel.fromFirestore(doc);
        } else {
          // For private profiles, return a redacted UserModel
          return UserModel(
            userId: data['userId'] ?? doc.id,
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            // Username is still populated as it might be used for direct search,
            // but display logic in UI should hide it for private profiles in lists.
            username: data['username'] ?? '',
            email: '', // Redacted
            phoneNumber: null, // Redacted
            bio: null, // Redacted
            interests: [], // Redacted
            travelStyles: [], // Redacted
            profilePicture: null, // Redacted
            isProfilePublic: false,
            // Friends list is sensitive, should not be exposed in a general user listing.
            friends: [], // Redacted for this general listing context
            // Notification preference is a user setting, not public info.
            notificationPreference:
                0, // Redacted or default non-sensitive value
          );
        }
      }).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      throw 'Failed to fetch users: $e';
    }
  }

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

  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await users.doc(userId).update({'interests': interests});
    } catch (e) {
      print('Error updating interests: $e');
      throw 'Failed to update interests: $e';
    }
  }

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

  Future<void> updateProfilePicture(String userId, String base64Image) async {
    try {
      await users.doc(userId).update({'profilePicture': base64Image});
    } catch (e) {
      print('Error updating profile picture: $e');
      throw 'Failed to update profile picture: $e';
    }
  }

  // Friend Request Logic
  Future<void> sendFriendRequest(String toUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not authenticated");

    if (currentUser.uid == toUserId) {
      throw Exception("Cannot send friend request to yourself.");
    }

    // Check if users are already friends
    final currentUserDoc = await users.doc(currentUser.uid).get();
    final currentUserData = UserModel.fromFirestore(currentUserDoc);
    if (currentUserData.friends.contains(toUserId)) {
      throw Exception("You are already friends with this user.");
    }

    final existingRequestQuery =
        await friendRequests
            .where('fromUserId', isEqualTo: currentUser.uid)
            .where('toUserId', isEqualTo: toUserId)
            // .where('status', isEqualTo: 'pending') // Check for any non-declined request
            .get();

    if (existingRequestQuery.docs.any(
      (doc) => doc['status'] == 'pending' || doc['status'] == 'accepted',
    )) {
      throw Exception(
        "Friend request already sent or user is already a friend.",
      );
    }

    final existingIncomingRequestQuery =
        await friendRequests
            .where('fromUserId', isEqualTo: toUserId)
            .where('toUserId', isEqualTo: currentUser.uid)
            // .where('status', isEqualTo: 'pending')
            .get();
    if (existingIncomingRequestQuery.docs.any(
      (doc) => doc['status'] == 'pending' || doc['status'] == 'accepted',
    )) {
      throw Exception(
        "This user has already sent you a friend request or is already your friend.",
      );
    }

    await friendRequests.add({
      'fromUserId': currentUser.uid,
      'toUserId': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'isNotification': false,
    });
  }

  Future<List<FriendRequest>> getIncomingFriendRequests() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final snapshot =
        await friendRequests
            .where('toUserId', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'pending')
            .where('isNotification', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => FriendRequest.fromFirestore(doc))
        .toList();
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not authenticated");

    final docRef = friendRequests.doc(requestId);
    final snap = await docRef.get();

    if (!snap.exists) throw Exception("Friend request not found.");

    final requestData = FriendRequest.fromFirestore(snap);

    if (requestData.toUserId != currentUser.uid) {
      throw Exception("Not authorized to respond to this request.");
    }
    if (requestData.status != 'pending') {
      throw Exception("This request has already been responded to.");
    }

    await docRef.update({
      'status': accept ? 'accepted' : 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    if (accept) {
      await users.doc(currentUser.uid).update({
        'friends': FieldValue.arrayUnion([requestData.fromUserId]),
      });
      await users.doc(requestData.fromUserId).update({
        'friends': FieldValue.arrayUnion([currentUser.uid]),
      });

      await friendRequests.add({
        'fromUserId': currentUser.uid,
        'toUserId': requestData.fromUserId,
        'status': 'accepted_notification',
        'createdAt': FieldValue.serverTimestamp(),
        'isNotification': true,
        'originalRequestId': requestId,
      });
    }
  }

  Future<List<FriendRequest>> getFriendRequestNotifications() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];
    final snapshot =
        await friendRequests
            .where('toUserId', isEqualTo: currentUser.uid)
            .where('isNotification', isEqualTo: true)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => FriendRequest.fromFirestore(doc))
        .toList();
  }

  Future<void> deleteNotification(String notificationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not authenticated");

    final docRef = friendRequests.doc(notificationId);
    final snap = await docRef.get();
    if (!snap.exists) throw Exception("Notification not found.");

    final requestData = FriendRequest.fromFirestore(snap);
    if (requestData.toUserId != currentUser.uid ||
        !requestData.isNotification) {
      throw Exception(
        "Not authorized to delete this item or it's not a notification.",
      );
    }
    await docRef.delete();
  }
}
