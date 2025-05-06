import 'package:flutter/widgets.dart';
import 'package:project/models/travel_plan.dart';

class TravelPlanProvider with ChangeNotifier {
  String planCategory = "none";

  List<TravelPlanModel> allPlans = [
    TravelPlanModel(
      title: 'Plan 1',
      date: DateTime(2025, 5, 10),
      location: 'Pansol',
      category: 'my',
    ),
    TravelPlanModel(
      title: 'Plan 2',
      date: DateTime(2025, 5, 9),
      location: 'Ubec',
      category: 'my',
    ),
    TravelPlanModel(
      title: 'Plan 3',
      date: DateTime(2025, 5, 15),
      location: 'Siargao',
      category: 'my',
    ),
    TravelPlanModel(
      title: 'Plan 4',
      date: DateTime(2025, 5, 12),
      location: 'Kahit saan',
      category: 'shared',
    ),
    TravelPlanModel(
      title: 'Plan 5',
      date: DateTime(2025, 5, 9),
      location: 'BGC',
      category: 'shared',
    ),
    TravelPlanModel(
      title: 'Plan 6',
      date: DateTime(2025, 5, 15),
      location: 'Baguio',
      category: 'shared',
    ),
    TravelPlanModel(
      title: 'Plan 7',
      date: DateTime(2025, 4, 6),
      location: 'Ewan',
      category: 'done',
    ),
    TravelPlanModel(
      title: 'Plan 8',
      date: DateTime(2025, 4, 9),
      location: 'Dorm',
      category: 'done',
    ),
  ];

  TravelPlanModel currentlyAdding = TravelPlanModel(
    title: '',
    date: DateTime.now(),
    location: '',
    category: '',
  );
  TravelPlanModel selectedPlan = TravelPlanModel(
    title: '',
    date: DateTime.now(),
    location: '',
    category: '',
  );

  void setFilterCategory(String category) {
    planCategory = category;
    notifyListeners();
  }

  void setCurrentlyAdding(TravelPlanModel plan) {
    currentlyAdding = plan;
    notifyListeners();
  }

  void addPlan(TravelPlanModel plan) {
    allPlans.insert(0, plan);
    notifyListeners();
  }

  void setSelectedPlan(TravelPlanModel plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  void removePlan(String title) {
    allPlans.removeWhere((p) => p.title == title);
    notifyListeners();
  }

  void updatePlan(TravelPlanModel updatedPlan) {
    final index = allPlans.indexWhere(
      (plan) => plan.title == selectedPlan.title,
    );
    if (index != -1) {
      allPlans[index] = updatedPlan;
      selectedPlan = updatedPlan;
      notifyListeners();
    }
  }
}

// context.read<TravelPlanProvider>().setFilterCategory("");
