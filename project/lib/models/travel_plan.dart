import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPlan {
  final String planId;
  final String createdBy;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final Map<String, dynamic> additionalInfo;
  final List<Map<String, dynamic>> itinerary;
  final List<String> sharedWith;
  final String? qrCodeData;

  TravelPlan({
    required this.planId,
    required this.createdBy,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.additionalInfo = const {},
    this.itinerary = const [],
    this.sharedWith = const [],
    this.qrCodeData,
  });

  factory TravelPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dateMap = data['date'] as Map<String, dynamic>;

    return TravelPlan(
      planId: doc.id,
      createdBy: data['createdBy'] ?? '',
      name: data['name'] ?? '',
      startDate: DateTime.parse(dateMap['start'] as String),
      endDate: DateTime.parse(dateMap['end'] as String),
      location: data['location'] ?? '',
      additionalInfo: Map<String, dynamic>.from(data['additionalInfo'] ?? {}),
      itinerary: List<Map<String, dynamic>>.from(data['itinerary'] ?? []),
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      qrCodeData: data['qrCodeData'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdBy': createdBy,
      'name': name,
      'date': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'location': location,
      'additionalInfo': additionalInfo,
      'itinerary': itinerary,
      'sharedWith': sharedWith,
      'qrCodeData': qrCodeData,
    };
  }
}
