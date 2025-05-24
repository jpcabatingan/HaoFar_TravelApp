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
      final User? currentUser = _auth.currentUser;

      if (currentUser != null && userId == currentUser.uid) {
        final defaultData = {
          'userId': userId,
          'email': currentUser.email ?? '',
          'username':
              currentUser.email?.split('@')[0] ??
              'traveler${DateTime.now().millisecondsSinceEpoch}',
          'firstName': currentUser.displayName?.split(' ').first ?? 'User',
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
          'profilePicture': null,
          'bio': null,
        };

        await users.doc(userId).set(defaultData);
        final newSnapshot = await users.doc(userId).get();
        return UserModel.fromFirestore(newSnapshot);
      } else {
        throw Exception(
          'User document not found and cannot create default for this user.',
        );
      }
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await users.get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
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

  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await users.doc(userId).update({'profilePicture': imageUrl});
    } catch (e) {
      print('Error updating profile picture: $e');
      throw 'Failed to update profile picture: $e';
    }
  }

  Future<void> sendFriendRequest(String toUserId) async {
    final currentUser = _auth.currentUser!;
    await friendRequests.add({
      'fromUserId': currentUser.uid,
      'toUserId': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      // isNotification defaults to false
    });
  }

  Future<List<FriendRequest>> getIncomingFriendRequests() async {
    final currentUser = _auth.currentUser!;
    final snapshot =
        await friendRequests
            .where('toUserId', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'pending')
            .get();

    final list =
        snapshot.docs.map((doc) => FriendRequest.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list;
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    final docRef = friendRequests.doc(requestId);
    final snap = await docRef.get();
    final data = snap.data() as Map<String, dynamic>;
    final originalFrom = data['fromUserId'] as String;
    final me = _auth.currentUser!;

    await docRef.update({
      'status': accept ? 'accepted' : 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    if (accept) {
      await friendRequests.add({
        'fromUserId': me.uid,
        'toUserId': originalFrom,
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
        'isNotification': true,
      });

      await users.doc(me.uid).update({
        'friends': FieldValue.arrayUnion([originalFrom]),
      });
      await users.doc(originalFrom).update({
        'friends': FieldValue.arrayUnion([me.uid]),
      });
    }
  }

  Future<List<FriendRequest>> getFriendRequestNotifications() async {
    final currentUser = _auth.currentUser!;
    final snapshot =
        await friendRequests
            .where('toUserId', isEqualTo: currentUser.uid)
            .where('isNotification', isEqualTo: true)
            .get();

    final list =
        snapshot.docs.map((doc) => FriendRequest.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list;
  }

  Future<void> deleteNotification(String requestId) async {
    await friendRequests.doc(requestId).delete();
  }
}
