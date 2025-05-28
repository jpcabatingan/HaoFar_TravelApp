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

          for (var doc in createdSnapshot.docs) {
            uniquePlans[doc.id] = doc;
          }
          for (var doc in sharedSnapshot.docs) {
            uniquePlans.putIfAbsent(doc.id, () => doc);
          }

          final List<DocumentSnapshot> allUnique = uniquePlans.values.toList();
          return allUnique.map((doc) => TravelPlan.fromFirestore(doc)).toList();
        })
        .handleError((e) {
          print('Error fetching travel plans: $e');
          throw Exception('Failed to fetch travel plans: $e');
        });
  }

  Future<void> createTravelPlan(TravelPlan travelPlan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (travelPlan.planId.isEmpty) {
      throw Exception('planId cannot be empty');
    }
    final planToSave = travelPlan.copyWith(createdBy: user.uid);

    await _db
        .collection('travelPlans')
        .doc(planToSave.planId)
        .set(planToSave.toFirestore());
  }

  Future<void> updateTravelPlan(TravelPlan travelPlan) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // The updateTravelPlan method is generic. It updates the whole plan document
    // with the provided TravelPlan object. This is suitable for checklist updates
    // as the provider will construct the new TravelPlan object with the modified checklist.
    await _db
        .collection('travelPlans')
        .doc(travelPlan.planId)
        .set(travelPlan.toFirestore(), SetOptions(merge: true));
    // Using SetOptions(merge: true) is good practice if you only intend to update
    // specific fields provided in toFirestore(), but since toFirestore() returns
    // the whole object, it effectively overwrites the document.
    // For checklist updates, this is fine as we pass the whole modified plan.
  }

  Future<void> deleteTravelPlan(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final planDoc = await _db.collection('travelPlans').doc(id).get();
    if (planDoc.exists && planDoc.data()?['createdBy'] != user.uid) {
      throw Exception('User not authorized to delete this plan');
    }
    await _db.collection('travelPlans').doc(id).delete();
  }

  Stream<TravelPlan?> getPlanById(String planId) {
    return _db
        .collection('travelPlans')
        .doc(planId)
        .snapshots()
        .map((doc) => doc.exists ? TravelPlan.fromFirestore(doc) : null)
        .handleError((e) {
          print('Error fetching plan by ID (stream): $e');
          return null;
        });
  }

  Future<TravelPlan?> getPlanByIdOnce(String planId) async {
    try {
      final doc = await _db.collection('travelPlans').doc(planId).get();
      return doc.exists ? TravelPlan.fromFirestore(doc) : null;
    } catch (e) {
      print('Error fetching plan by ID (once): $e');
      rethrow;
    }
  }

  Future<void> sharePlanWithUserByUsername(
    String planId,
    String targetUsername,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final usersQuery =
        await _db
            .collection('users')
            .where('username', isEqualTo: targetUsername)
            .limit(1)
            .get();
    if (usersQuery.docs.isEmpty) {
      throw Exception('User with username "$targetUsername" not found.');
    }
    final targetUserId = usersQuery.docs.first.id;
    final targetUserData = usersQuery.docs.first.data();

    if (targetUserId == currentUser.uid) {
      throw Exception('You cannot share a plan with yourself.');
    }
    if (targetUserData['isProfilePublic'] == false) {
      throw Exception(
        'Cannot share plan: User "$targetUsername" has a private profile.',
      );
    }

    final planRef = _db.collection('travelPlans').doc(planId);
    final planDoc = await planRef.get();
    if (!planDoc.exists) {
      throw Exception('Travel plan not found.');
    }
    final planData = TravelPlan.fromFirestore(planDoc);
    if (planData.createdBy != currentUser.uid) {
      throw Exception('Only the creator can share this plan.');
    }
    if (planData.sharedWith.contains(targetUserId)) {
      throw Exception('Plan already shared with this user.');
    }

    await planRef.update({
      'sharedWith': FieldValue.arrayUnion([targetUserId]),
    });
  }

  Future<void> removeUserFromSharedPlan(
    String planId,
    String userIdToRemove,
  ) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final planRef = _db.collection('travelPlans').doc(planId);
    final planDoc = await planRef.get();
    if (!planDoc.exists) {
      throw Exception('Travel plan not found.');
    }
    final planData = TravelPlan.fromFirestore(planDoc);

    if (planData.createdBy != currentUser.uid) {
      throw Exception('Only the creator can remove users from this plan.');
    }

    await planRef.update({
      'sharedWith': FieldValue.arrayRemove([userIdToRemove]),
    });
  }
}
