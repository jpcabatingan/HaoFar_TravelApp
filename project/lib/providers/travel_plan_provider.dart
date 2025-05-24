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
  User? get currentUser => _auth.currentUser;
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
          _isLoading = true;
          _error = null;
          notifyListeners();
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
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _plansSubscription = _travelPlanApi.getTravelPlans().listen(
      (plansData) {
        _plans = plansData;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = "Failed to fetch travel plans: ${e.toString()}";
        _isLoading = false;
        _plans = [];
        notifyListeners();
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
    notifyListeners();
    try {
      await _travelPlanApi.createTravelPlan(planToSave);
      _isLoading = false;
    } catch (e) {
      _error = "Failed to create plan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlan(TravelPlan plan) async {
    // This method is used by edit_plan.dart and now also for checklist updates.
    _isLoading =
        true; // Consider if this global loading is appropriate for quick checklist toggles.
    notifyListeners();
    try {
      await _travelPlanApi.updateTravelPlan(
        plan,
      ); // updateTravelPlan in API handles the full plan update
      _isLoading = false;
      // Stream will update the list.
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
      _isLoading = false;
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
      _isLoading = false;
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
      _isLoading = false;
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
    // Fetch the current plan. It's important to work with the latest version.
    TravelPlan? currentPlan = await getPlanById(
      planId,
    ); // Use existing method to fetch once
    if (currentPlan == null) {
      _error = "Could not find plan to update checklist.";
      notifyListeners();
      throw Exception(_error);
    }

    // Create a mutable copy of the checklist
    List<Map<String, dynamic>> updatedChecklist =
        List<Map<String, dynamic>>.from(currentPlan.checklist);

    if (itemIndex < 0 || itemIndex >= updatedChecklist.length) {
      _error = "Invalid checklist item index.";
      notifyListeners();
      throw Exception(_error);
    }

    // Update the specific item
    updatedChecklist[itemIndex] = {
      ...updatedChecklist[itemIndex], // Preserve other potential properties of the map
      'done': newStatus,
    };

    // Create the updated plan object
    TravelPlan planWithUpdatedChecklist = currentPlan.copyWith(
      additionalInfo: {
        ...currentPlan.additionalInfo, // Preserve other additionalInfo
        'checklist': updatedChecklist,
      },
    );

    // Use the general updatePlan method
    // No need to set _isLoading here as updatePlan will do it.
    try {
      await updatePlan(planWithUpdatedChecklist);
      // The stream in PlanDetails will reflect the change.
    } catch (e) {
      // Error already handled by updatePlan, but can re-log or re-throw if specific handling needed here
      print("Error in toggleChecklistItemStatus after calling updatePlan: $e");
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (_auth.currentUser != null) {
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
    // This method is less used now that PlanDetails uses getPlanStream.
    // Kept for potential direct fetches if needed.
    // _isLoading = true; // Avoid setting global loading for this internal fetch
    // notifyListeners();
    try {
      final plan = await _travelPlanApi.getPlanByIdOnce(planId);
      // _isLoading = false;
      return plan;
    } catch (e) {
      _error = "Failed to get plan by ID: ${e.toString()}";
      // _isLoading = false;
      notifyListeners(); // Notify if error occurs
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
