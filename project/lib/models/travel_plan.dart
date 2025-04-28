import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPlan {
  final String planId;
  final String createdBy;
  final String name;
  final Map<String, dynamic> date; // {start: Timestamp, end: Timestamp}
  final String location;
  final Map<String, dynamic>? additionalInfo;
  final List<Map<String, dynamic>> itinerary;
  final List<String> sharedWith;
  final String? qrCodeData;

  TravelPlan({
    required this.planId,
    required this.createdBy,
    required this.name,
    required this.date,
    required this.location,
    this.additionalInfo,
    this.itinerary = const [],
    this.sharedWith = const [],
    this.qrCodeData,
  });

  // Convert Firestore Document to TravelPlan
  factory TravelPlan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TravelPlan(
      planId: data['planId'] ?? doc.id,
      createdBy: data['createdBy'] ?? '',
      name: data['name'] ?? '',
      date: Map<String, dynamic>.from(data['date'] ?? {}),
      location: data['location'] ?? '',
      additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
      itinerary: List<Map<String, dynamic>>.from(data['itinerary'] ?? []),
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      qrCodeData: data['qrCodeData'],
    );
  }

  // Convert TravelPlan to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'createdBy': createdBy,
      'name': name,
      'date': date,
      'location': location,
      'additionalInfo': additionalInfo,
      'itinerary': itinerary,
      'sharedWith': sharedWith,
      'qrCodeData': qrCodeData,
    };
  }
}
