import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/friend_request.dart';
import 'package:project/models/user.dart' as custom_user;

class FirebaseUsersApi {
  static final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _usersCollection = 'users';
  static const String _friendRequestsCollection = 'friendRequests';
  static const String _friendsCollection = 'friends';

  Stream<List<custom_user.User>> getOtherUsers() {
    return _db
        .collection(_usersCollection)
        .where('isProfilePublic', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .where((doc) => doc.id != _auth.currentUser?.uid)
                  .map((doc) => custom_user.User.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> sendFriendRequest(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Check if the friend request already exists
    final existingRequest =
        await _db
            .collection(_friendRequestsCollection)
            .where('from', isEqualTo: currentUser.uid)
            .where('to', isEqualTo: userId)
            .get();

    if (existingRequest.docs.isEmpty) {
      await _db.collection(_friendRequestsCollection).add({
        'from': currentUser.uid,
        'to': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<FriendRequest>> getFriendRequests() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _db
        .collection(_friendRequestsCollection)
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => FriendRequest.fromFirestore(doc))
                  .toList(),
        );
  }

  Future<void> acceptFriendRequest(String requestId) async {
    final requestDoc = _db.collection(_friendRequestsCollection).doc(requestId);
    final requestSnapshot = await requestDoc.get();

    if (requestSnapshot.exists) {
      final data = requestSnapshot.data() as Map<String, dynamic>;
      final fromUserId = data['fromUserId'];
      final toUserId = data['toUserId'];

      // Update the friend request status to 'accepted'
      await requestDoc.update({'status': 'accepted'});

      // Add both users to each other's friends list
      await _db.collection(_friendsCollection).doc(fromUserId).update({
        'friends': FieldValue.arrayUnion([toUserId]),
      });
      await _db.collection(_friendsCollection).doc(toUserId).update({
        'friends': FieldValue.arrayUnion([fromUserId]),
      });
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    final requestDoc = _db.collection(_friendRequestsCollection).doc(requestId);
    await requestDoc.delete();
  }

  Future<List<custom_user.User>> getFriends() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final friendsSnapshot =
        await _db.collection(_friendsCollection).doc(userId).get();

    if (friendsSnapshot.exists) {
      final friendsData = friendsSnapshot.data() as Map<String, dynamic>;
      final friendIds = List<String>.from(friendsData['friends'] ?? []);

      final friendDocs =
          await _db
              .collection(_usersCollection)
              .where(FieldPath.documentId, whereIn: friendIds)
              .get();

      return friendDocs.docs
          .map((doc) => custom_user.User.fromFirestore(doc))
          .toList();
    }

    return [];
  }

  Future<void> removeFriend(String friendId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Remove from user's friends list
    await _db.collection(_friendsCollection).doc(userId).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });

    // Remove from friend's friends list
    await _db.collection(_friendsCollection).doc(friendId).update({
      'friends': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> updateUserProfile(custom_user.User user) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.collection(_usersCollection).doc(userId).update({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'username': user.username,
      'phoneNumber': user.phoneNumber,
      'interests': user.interests,
      'travelStyles': user.travelStyles,
      'profilePicture': user.profilePicture,
      'isProfilePublic': user.isProfilePublic,
    });
  }

  Future<custom_user.User?> getUserById(String userId) async {
    final doc = await _db.collection(_usersCollection).doc(userId).get();
    if (doc.exists) {
      return custom_user.User.fromFirestore(doc);
    }
    return null;
  }
}
