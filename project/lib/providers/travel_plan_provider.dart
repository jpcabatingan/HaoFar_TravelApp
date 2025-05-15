// providers/travel_plan_provider.dart
import 'dart:async'; // Import for StreamSubscription
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:project/api/travel_plan_api.dart';
import 'package:project/models/travel_plan.dart';

class TravelPlanProvider with ChangeNotifier {
  final FirebaseTravelPlanApi _travelPlanApi;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<List<TravelPlan>>?
  _plansSubscription; // To manage plan data stream

  String planCategory = "none";
  List<TravelPlan> _plans = [];
  bool _isLoading = false; // Start with false, set to true when fetching
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
    _isLoading =
        true; // Initially, we might be loading auth state or first set of plans
    notifyListeners();

    _authStateSubscription = _auth.authStateChanges().listen(
      (User? firebaseUser) {
        _plansSubscription
            ?.cancel(); // Cancel any existing plan subscription from previous user
        _plans = []; // Clear previous user's plans immediately

        if (firebaseUser == null) {
          // User logged out
          _isLoading = false;
          _error = null;
          _draftPlan = null; // Clear draft plan
          notifyListeners();
        } else {
          // User logged in, fetch new plans
          _isLoading = true;
          _error = null; // Clear previous errors
          notifyListeners(); // Notify UI that we are loading
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
    // Ensure isLoading is true before starting the fetch.
    // This might be redundant if _listenToAuthChanges already set it, but good for direct calls too.
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    _plansSubscription = _travelPlanApi.getTravelPlans().listen(
      (plansData) {
        // Renamed to avoid conflict with _plans
        final uniquePlans = <String, TravelPlan>{};
        for (var plan in plansData) {
          uniquePlans[plan.planId] = plan; // Use planId as key for uniqueness
        }
        _plans = uniquePlans.values.toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = "Failed to fetch travel plans: ${e.toString()}";
        _isLoading = false;
        _plans = []; // Clear plans on error
        notifyListeners();
      },
    );
  }

  List<TravelPlan> get filteredPlans {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    switch (planCategory) {
      case 'my':
        return _plans.where((p) => p.createdBy == userId).toList();
      case 'shared':
        // Only show plans shared with the user that they didn't create.
        return _plans
            .where(
              (p) => p.sharedWith.contains(userId) && p.createdBy != userId,
            )
            .toList();
      case 'done':
        final now = DateTime.now();
        return _plans.where((p) => p.endDate.isBefore(now)).toList();
      default: // "none" - should show all plans relevant to the user (created by OR shared with)
        // The _travelPlanApi.getTravelPlans() already fetches both created and shared plans.
        // So, _plans already contains all relevant plans.
        return _plans;
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
    // Optimistically update UI or wait for stream, for now, rely on stream
    _isLoading = true; // Indicate activity
    notifyListeners();
    try {
      await _travelPlanApi.createTravelPlan(plan);
      // Data will be updated by the Firestore stream via _fetchPlansForCurrentUser.
      // No need to manually add to _plans if stream is working.
      // If immediate feedback is needed before stream updates, can add optimistically:
      // _plans.add(plan); // But this might cause duplicates if stream also adds it.
      // For now, let the stream handle it. A manual refresh() could be an option too.
      _isLoading = false; // Reset loading after operation
      // notifyListeners(); // Stream will notify
    } catch (e) {
      _error = "Failed to create plan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlan(TravelPlan plan) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _travelPlanApi.updateTravelPlan(plan);
      // Stream should update the list.
      _isLoading = false;
      // notifyListeners(); // Stream will notify
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
      // Stream should update the list.
      _isLoading = false;
      // notifyListeners(); // Stream will notify
    } catch (e) {
      _error = "Failed to delete plan: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    // This is a manual refresh, typically for pull-to-refresh.
    // It should re-initiate the fetching process for the current user.
    if (_auth.currentUser != null) {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _plansSubscription?.cancel(); // Cancel existing subscription
      _fetchPlansForCurrentUser(); // Re-fetch/re-subscribe for current user
    } else {
      // No user, ensure state is clear
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
    // This fetches a single plan, should be fine as is.
    return _travelPlanApi.getPlanById(planId);
  }

  Future<TravelPlan?> getPlanById(String planId) async {
    // This fetches a single plan once, should be fine as is.
    _isLoading = true;
    notifyListeners();
    try {
      final plan = await _travelPlanApi.getPlanByIdOnce(planId);
      _isLoading = false;
      notifyListeners();
      return plan;
    } catch (e) {
      _error = "Failed to get plan by ID: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
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
