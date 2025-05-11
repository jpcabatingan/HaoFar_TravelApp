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

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await _travelPlanApi
        .getTravelPlans()
        .first
        .then((plans) {
          final uniquePlans = <String, TravelPlan>{};
          for (var plan in plans) {
            uniquePlans[plan.planId] = plan;
          }
          _plans = uniquePlans.values.toList();
          _isLoading = false;
          _error = null;
          notifyListeners();
        })
        .catchError((e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        });
  }

  void setFilterCategory(String category) {
    if (planCategory != category) {
      planCategory = category;
      notifyListeners();
    }
  }

  Future<void> createPlan(TravelPlan plan) async {
    if (plan.planId.isEmpty) {
      throw Exception("planId cannot be empty");
    }

    try {
      await _travelPlanApi.createTravelPlan(plan);

      // ✅ Avoid adding duplicate if it already exists
      final existingIndex = _plans.indexWhere((p) => p.planId == plan.planId);
      if (existingIndex == -1) {
        _plans.add(plan);
      } else {
        _plans[existingIndex] = plan;
      }

      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePlan(TravelPlan plan) async {
    try {
      await _travelPlanApi.updateTravelPlan(plan);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _travelPlanApi.deleteTravelPlan(planId);
      await refresh();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _init(); // Make _init() async and await it
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

  void clearDraftPlan() {
    _draftPlan = null;
    notifyListeners();
  }

  Stream<TravelPlan?> getPlanStream(String planId) {
    return _travelPlanApi.getPlanById(planId);
  }

  Future<TravelPlan?> getPlanById(String planId) async {
    try {
      return await _travelPlanApi.getPlanByIdOnce(planId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
