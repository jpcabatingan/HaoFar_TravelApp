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

  TravelPlan copyWith({
    String? planId,
    String? createdBy,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    Map<String, dynamic>? additionalInfo,
    List<Map<String, dynamic>>? itinerary,
    List<String>? sharedWith,
    String? qrCodeData,
  }) {
    return TravelPlan(
      planId: planId ?? this.planId,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      itinerary: itinerary ?? this.itinerary,
      sharedWith: sharedWith ?? this.sharedWith,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  String get flightDetails => additionalInfo['flightDetails'] ?? '';
  String get accommodation => additionalInfo['accommodation'] ?? '';
  List<String> get notes => List<String>.from(additionalInfo['notes'] ?? []);
  List<String> get checklist =>
      List<String>.from(additionalInfo['checklist'] ?? []);

  factory TravelPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extract and safely cast nested maps
    final dateMap = data['date'] as Map<String, dynamic>? ?? {};
    final additionalInfoMap =
        data['additionalInfo'] as Map<String, dynamic>? ?? {};
    final itineraryList = data['itinerary'] as List<dynamic>? ?? [];
    final sharedWithList = data['sharedWith'] as List<dynamic>? ?? [];

    return TravelPlan(
      planId: data['planId'] as String? ?? doc.id,
      createdBy: data['createdBy'] as String? ?? '',
      name: data['name'] as String? ?? '',
      startDate: _parseDate(dateMap['start']),
      endDate: _parseDate(dateMap['end']),
      location: data['location'] as String? ?? '',
      additionalInfo: Map<String, dynamic>.from(additionalInfoMap),
      itinerary:
          itineraryList.map((item) => item as Map<String, dynamic>).toList(),
      sharedWith: sharedWithList.map((item) => item as String).toList(),
      qrCodeData: data['qrCodeData'] as String?,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
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
