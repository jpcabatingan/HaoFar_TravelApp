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
        .map((snapshots) {
          final createdSnapshot = snapshots[0] as QuerySnapshot;
          final sharedSnapshot = snapshots[1] as QuerySnapshot;

          final allDocs = <DocumentSnapshot>[
            ...createdSnapshot.docs,
            ...sharedSnapshot.docs,
          ];

          final uniquePlans = <String, DocumentSnapshot>{};

          for (var doc in allDocs) {
            uniquePlans[doc.id] = doc;
          }

          return uniquePlans.values
              .map((doc) => TravelPlan.fromFirestore(doc))
              .toList();
        })
        .handleError((e) {
          throw Exception('Failed to fetch travel plans: $e');
        });
  }

  Future<String> createTravelPlan(TravelPlan travelPlan) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final docRef = await _db
        .collection('travelPlans')
        .add(travelPlan.toFirestore());
    return docRef.id;
  }

  Future<void> updateTravelPlan(TravelPlan travelPlan) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _db
        .collection('travelPlans')
        .doc(travelPlan.planId)
        .update(travelPlan.toFirestore());
  }

  Future<void> deleteTravelPlan(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _db.collection('travelPlans').doc(id).delete();
  }
}
