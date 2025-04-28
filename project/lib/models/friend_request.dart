import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      requestId: doc.id,
      fromUserId: data['fromUserId'],
      toUserId: data['toUserId'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
