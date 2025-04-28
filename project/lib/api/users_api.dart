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
}
