import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String toUserId;
  final String status;  
  final DateTime createdAt;
  final DateTime? respondedAt; 
  final bool isNotification;    

  FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.isNotification = false,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      requestId: doc.id,
      fromUserId: data['fromUserId'] as String,
      toUserId: data['toUserId'] as String,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      isNotification: data['isNotification'] as bool? ?? false,
    );
  }
}
