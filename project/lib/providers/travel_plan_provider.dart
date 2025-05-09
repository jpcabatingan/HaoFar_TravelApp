// providers/travel_plan_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:project/api/travel_plan_api.dart';
import 'package:project/models/travel_plan.dart';

class TravelPlanProvider with ChangeNotifier {
  final FirebaseTravelPlanApi _travelPlanApi;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String planCategory = "none";
  List<TravelPlan> _plans = [];
  bool _isLoading = true;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  TravelPlan? _selectedPlan;
  TravelPlan? get selectedPlan => _selectedPlan;

  User? get currentUser => _auth.currentUser;
  TravelPlan? _draftPlan;
  TravelPlan? get draftPlan => _draftPlan;

  TravelPlanProvider(this._travelPlanApi) {
    _init();
  }

  List<TravelPlan> get filteredPlans {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    switch (planCategory) {
      case 'my':
        return _plans.where((p) => p.createdBy == userId).toList();
      case 'shared':
        return _plans.where((p) => p.sharedWith.contains(userId)).toList();
      case 'done':
        final now = DateTime.now();
        return _plans.where((p) => p.endDate.isBefore(now)).toList();
      default:
        return _plans;
    }
  }

  void _init() {
    _travelPlanApi.getTravelPlans().listen(
      (plans) {
        _plans = plans;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setFilterCategory(String category) {
    if (planCategory != category) {
      planCategory = category;
      notifyListeners();
    }
  }

  Future<void> createPlan(TravelPlan plan) async {
    try {
      await _travelPlanApi.createTravelPlan(plan);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlan(TravelPlan plan) async {
    try {
      await _travelPlanApi.updateTravelPlan(plan);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _travelPlanApi.deleteTravelPlan(planId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void refresh() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _init(); // Re-fetch data
  }

  void setSelectedPlan(TravelPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void clearSelectedPlan() {
    _selectedPlan = null;
    notifyListeners();
  }

  void setDraftPlan(TravelPlan plan) {
    _draftPlan = plan;
    notifyListeners();
  }

  void updateDraftAdditionalInfo(Map<String, dynamic> info) {
    if (_draftPlan != null) {
      _draftPlan = _draftPlan!.copyWith(additionalInfo: info);
    }
    notifyListeners();
  }
}
