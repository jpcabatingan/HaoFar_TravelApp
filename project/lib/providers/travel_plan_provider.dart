// providers/travel_plan_provider.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:project/api/travel_plan_api.dart';
import 'package:project/models/travel_plan.dart';

class TravelPlanProvider with ChangeNotifier {
  final FirebaseTravelPlanApi _travelPlanApi;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<List<TravelPlan>>? _plansSubscription;

  String planCategory = "none";
  List<TravelPlan> _plans = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser =>
      _auth.currentUser; // Changed from currentUserAuth for consistency
  TravelPlan? _draftPlan;
  TravelPlan? get draftPlan => _draftPlan;

  TravelPlanProvider(this._travelPlanApi) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _isLoading = true;
    notifyListeners();

    _authStateSubscription = _auth.authStateChanges().listen(
      (User? firebaseUser) {
        _plansSubscription?.cancel();
        _plans = [];

        if (firebaseUser == null) {
          _isLoading = false;
          _error = null;
          _draftPlan = null;
          notifyListeners();
        } else {
          _isLoading = true; // Set loading true before fetching
          _error = null;
          notifyListeners(); // Notify UI that we are about to fetch
          _fetchPlansForCurrentUser();
        }
      },
      onError: (e) {
        _plans = [];
        _isLoading = false;
        _error = "Auth listener error: ${e.toString()}";
        notifyListeners();
      },
    );
  }

  void _fetchPlansForCurrentUser() {
    // Ensure isLoading is true if this method is called directly after an operation
    // or during initial load. The stream listener will set it to false.
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _plansSubscription = _travelPlanApi.getTravelPlans().listen(
      (plansData) {
        _plans = plansData;
        _isLoading =
            false; // Correctly set isLoading to false when data is received
        _error = null;
        notifyListeners(); // Notify UI to rebuild with new data and loading state
      },
      onError: (e) {
        _error = "Failed to fetch travel plans: ${e.toString()}";
        _isLoading = false; // Also set isLoading to false on error
        _plans = [];
        notifyListeners(); // Notify UI about the error and loading state
      },
      onDone: () {
        // If the stream closes unexpectedly while we thought we were loading, update state.
        // This is less common for Firestore streams unless manually closed or due to auth changes.
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  List<TravelPlan> get filteredPlans {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    List<TravelPlan> plansToFilter = List.from(_plans);
    DateTime now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    switch (planCategory) {
      case 'my':
        return plansToFilter.where((p) {
          DateTime planEndDate = DateTime(
            p.endDate.year,
            p.endDate.month,
            p.endDate.day,
          );
          return p.createdBy == userId &&
              (planEndDate.isAtSameMomentAs(now) || planEndDate.isAfter(now));
        }).toList();
      case 'shared':
        return plansToFilter.where((p) {
          DateTime planEndDate = DateTime(
            p.endDate.year,
            p.endDate.month,
            p.endDate.day,
          );
          return p.sharedWith.contains(userId) &&
              p.createdBy != userId &&
              (planEndDate.isAtSameMomentAs(now) || planEndDate.isAfter(now));
        }).toList();
      case 'done':
        return plansToFilter.where((p) {
          DateTime planEndDate = DateTime(
            p.endDate.year,
            p.endDate.month,
            p.endDate.day,
          );
          return (p.createdBy == userId || p.sharedWith.contains(userId)) &&
              planEndDate.isBefore(now);
        }).toList();
      case 'none':
      default:
        return plansToFilter.where((p) {
          DateTime planEndDate = DateTime(
            p.endDate.year,
            p.endDate.month,
            p.endDate.day,
          );
          return (p.createdBy == userId || p.sharedWith.contains(userId)) &&
              (planEndDate.isAtSameMomentAs(now) || planEndDate.isAfter(now));
        }).toList();
    }
  }

  void setFilterCategory(String category) {
    if (planCategory != category) {
      planCategory = category;
      notifyListeners();
    }
  }

  Future<void> createPlan(TravelPlan plan) async {
    if (plan.planId.isEmpty) {
      _error = "Plan ID cannot be empty during creation.";
      notifyListeners();
      throw Exception("planId cannot be empty");
    }
    final user = _auth.currentUser;
    if (user == null) {
      _error = "User not authenticated.";
      notifyListeners();
      throw Exception("User not authenticated");
    }
    final planToSave = plan.copyWith(createdBy: user.uid);

    _isLoading = true;
    notifyListeners(); // Notify that an operation has started
    try {
      await _travelPlanApi.createTravelPlan(planToSave);
      // DO NOT set _isLoading = false here. The stream will handle it.
    } catch (e) {
      _error = "Failed to create plan: ${e.toString()}";
      _isLoading =
          false; // Set loading to false only on error during the operation itself
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlan(TravelPlan plan) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _travelPlanApi.updateTravelPlan(plan);
      // DO NOT set _isLoading = false here. The stream will handle it.
    } catch (e) {
      _error = "Failed to update plan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _travelPlanApi.deleteTravelPlan(planId);
      // DO NOT set _isLoading = false here. The stream will handle it.
    } catch (e) {
      _error = "Failed to delete plan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sharePlanWithUserByUsername(
    String planId,
    String targetUsername,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _travelPlanApi.sharePlanWithUserByUsername(planId, targetUsername);
      // DO NOT set _isLoading = false here. The stream will handle it.
    } catch (e) {
      _error = "Failed to share plan by username: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeUserFromSharedPlan(
    String planId,
    String userIdToRemove,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _travelPlanApi.removeUserFromSharedPlan(planId, userIdToRemove);
      // DO NOT set _isLoading = false here. The stream will handle it.
    } catch (e) {
      _error = "Failed to remove user from plan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleChecklistItemStatus(
    String planId,
    int itemIndex,
    bool newStatus,
  ) async {
    TravelPlan? currentPlan = await getPlanById(planId);
    if (currentPlan == null) {
      _error = "Could not find plan to update checklist.";
      notifyListeners();
      throw Exception(_error);
    }

    List<Map<String, dynamic>> updatedChecklist =
        List<Map<String, dynamic>>.from(currentPlan.checklist);

    if (itemIndex < 0 || itemIndex >= updatedChecklist.length) {
      _error = "Invalid checklist item index.";
      notifyListeners();
      throw Exception(_error);
    }

    updatedChecklist[itemIndex] = {
      ...updatedChecklist[itemIndex],
      'done': newStatus,
    };

    TravelPlan planWithUpdatedChecklist = currentPlan.copyWith(
      additionalInfo: {
        ...currentPlan.additionalInfo,
        'checklist': updatedChecklist,
      },
    );

    // updatePlan will set its own isLoading and rely on the stream.
    try {
      await updatePlan(planWithUpdatedChecklist);
    } catch (e) {
      print("Error in toggleChecklistItemStatus after calling updatePlan: $e");
      // Error is handled by updatePlan's catch block.
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (_auth.currentUser != null) {
      // _isLoading is set to true by _fetchPlansForCurrentUser if it's not already true.
      // No need to set it explicitly here if _fetchPlansForCurrentUser handles it.
      // However, to ensure UI shows loading during manual refresh, it's good to set it.
      _isLoading = true;
      _error = null;
      notifyListeners();
      _plansSubscription?.cancel();
      _fetchPlansForCurrentUser();
    } else {
      _plans = [];
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  void setDraftPlan(TravelPlan plan) {
    _draftPlan = plan;
    notifyListeners();
  }

  void updateDraftAdditionalInfo(Map<String, dynamic> info) {
    if (_draftPlan != null) {
      _draftPlan = _draftPlan!.copyWith(additionalInfo: info);
      notifyListeners();
    }
  }

  void clearDraftPlan() {
    _draftPlan = null;
    notifyListeners();
  }

  Stream<TravelPlan?> getPlanStream(String planId) {
    return _travelPlanApi.getPlanById(planId);
  }

  Future<TravelPlan?> getPlanById(String planId) async {
    // This is a one-time fetch, should not affect global _isLoading for the list.
    try {
      final plan = await _travelPlanApi.getPlanByIdOnce(planId);
      return plan;
    } catch (e) {
      // Avoid setting global _error for this specific fetch unless it's unrecoverable
      // and needs to be shown widely.
      print(
        "Error in getPlanById (one-time fetch for toggleChecklistItemStatus): $e",
      );
      // Not calling notifyListeners() for _error here to avoid broad UI changes for an internal fetch.
      rethrow;
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _plansSubscription?.cancel();
    super.dispose();
  }
}
