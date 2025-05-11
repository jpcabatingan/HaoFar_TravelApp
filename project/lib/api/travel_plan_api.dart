import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/travel_plan.dart';
import 'package:async/async.dart';

class FirebaseTravelPlanApi {
  static final _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<TravelPlan>> getTravelPlans() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

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

    return StreamZip([createdStream, sharedStream])
        .asyncMap((snapshots) async {
          final createdSnapshot = snapshots[0] as QuerySnapshot;
          final sharedSnapshot = snapshots[1] as QuerySnapshot;

          final uniquePlans = <String, DocumentSnapshot>{};

          // Add created plans
          for (var doc in createdSnapshot.docs) {
            uniquePlans[doc.id] = doc;
          }

          // Add shared plans, avoiding duplicates
          for (var doc in sharedSnapshot.docs) {
            uniquePlans.putIfAbsent(doc.id, () => doc);
          }

          final List<DocumentSnapshot> allUnique = uniquePlans.values.toList();
          return allUnique.map((doc) => TravelPlan.fromFirestore(doc)).toList();
        })
        .handleError((e) {
          throw Exception('Failed to fetch travel plans: $e');
        });
  }

  Future<void> createTravelPlan(TravelPlan travelPlan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // ✅ Ensure planId is not empty
    if (travelPlan.planId.isEmpty) {
      throw Exception('planId cannot be empty');
    }

    await _db
        .collection('travelPlans')
        .doc(travelPlan.planId)
        .set(travelPlan.toFirestore());
  }

  Future<void> updateTravelPlan(TravelPlan travelPlan) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Use set() to fully replace the document
    await _db
        .collection('travelPlans')
        .doc(travelPlan.planId)
        .set(travelPlan.toFirestore());
  }

  Future<void> deleteTravelPlan(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _db.collection('travelPlans').doc(id).delete();
  }

  Stream<TravelPlan?> getPlanById(String planId) {
    return _db
        .collection('travelPlans')
        .doc(planId)
        .snapshots()
        .map((doc) => doc.exists ? TravelPlan.fromFirestore(doc) : null);
  }

  Future<TravelPlan?> getPlanByIdOnce(String planId) async {
    final doc = await _db.collection('travelPlans').doc(planId).get();
    return doc.exists ? TravelPlan.fromFirestore(doc) : null;
  }
}
