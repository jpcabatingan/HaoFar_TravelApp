import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/travel_plan.dart';

class FirebaseTravelPlanApi {
  static final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<TravelPlan>> getTravelPlans() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    // Get both created and shared plans
    final createdStream =
        _db
            .collection('travelPlans')
            .where('createdBy', isEqualTo: user.uid)
            .snapshots();

    final sharedStream =
        _db
            .collection('travelPlans')
            .where('sharedWith', arrayContains: user.uid)
            .snapshots();

    return createdStream.asyncExpand((createdSnapshot) {
      return sharedStream.map((sharedSnapshot) {
        final allDocs = [...createdSnapshot.docs, ...sharedSnapshot.docs];
        // Remove duplicates
        final uniqueDocs =
            allDocs
                .fold<Map<String, DocumentSnapshot>>(
                  {},
                  (map, doc) => map..[doc.id] = doc,
                )
                .values
                .toList();

        return uniqueDocs.map((doc) => TravelPlan.fromFirestore(doc)).toList();
      });
    });
  }

  // Define methods to interact with Firebase for travel plans
  Future<String> createTravelPlan(TravelPlan travelPlan) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Authentication required');

      final docRef = await _db.collection('travelPlans').add({
        'createdBy': user.uid,
        'name': travelPlan.name,
        'date': travelPlan.date,
        'location': travelPlan.location,
        'additionalInfo': travelPlan.additionalInfo,
        'itinerary': travelPlan.itinerary,
        'sharedWith': travelPlan.sharedWith,
        'qrCodeData': travelPlan.qrCodeData,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create plan: ${e.toString()}');
    }
  }

  Future<TravelPlan?> getTravelPlan(String id) async {
    try {
      final doc = await _db.collection('travelPlans').doc(id).get();
      if (doc.exists) {
        return TravelPlan.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to fetch plan: ${e.toString()}');
    }
  }

  Future<void> updateTravelPlan(TravelPlan travelPlan) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Authentication required');

      await _db.collection('travelPlans').doc(travelPlan.planId).update({
        'name': travelPlan.name,
        'date': travelPlan.date,
        'location': travelPlan.location,
        'additionalInfo': travelPlan.additionalInfo,
        'itinerary': travelPlan.itinerary,
        'sharedWith': travelPlan.sharedWith,
        'qrCodeData': travelPlan.qrCodeData,
      });
    } catch (e) {
      throw Exception('Failed to update plan: ${e.toString()}');
    }
  }

  Future<void> deleteTravelPlan(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Authentication required');

      await _db.collection('travelPlans').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete plan: ${e.toString()}');
    }
  }
}
