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
        final uniquePlans = <String, TravelPlan>{};
        for (var plan in plansData) {
          uniquePlans[plan.planId] = plan;
        }
        _plans = uniquePlans.values.toList();
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

    switch (planCategory) {
      case 'my':
        return _plans.where((p) => p.createdBy == userId).toList();
      case 'shared':
        return _plans
            .where(
              (p) => p.sharedWith.contains(userId) && p.createdBy != userId,
            )
            .toList();
      case 'done':
        final now = DateTime.now();
        return _plans.where((p) => p.endDate.isBefore(now)).toList();
      default:
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
    _isLoading = true;
    notifyListeners();
    try {
      await _travelPlanApi.createTravelPlan(plan);
      _isLoading = false;
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
      _isLoading = false;
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