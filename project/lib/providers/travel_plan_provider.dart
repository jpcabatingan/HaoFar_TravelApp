import 'package:flutter/widgets.dart';
import 'package:project/models/travel_plan.dart';

class TravelPlanProvider with ChangeNotifier {
  String planCategory = "none";

  List<TravelPlan> allPlans = [
    TravelPlan(
      title: 'Plan 1',
      date: DateTime(2025, 5, 10),
      location: 'Pansol',
      category: 'my',
    ),
    TravelPlan(
      title: 'Plan 2',
      date: DateTime(2025, 5, 9),
      location: 'Ubec',
      category: 'my',
    ),
    TravelPlan(
      title: 'Plan 3',
      date: DateTime(2025, 5, 15),
      location: 'Siargao',
      category: 'my',
    ),
    TravelPlan(
      title: 'Plan 4',
      date: DateTime(2025, 5, 12),
      location: 'Kahit saan',
      category: 'shared',
    ),
    TravelPlan(
      title: 'Plan 5',
      date: DateTime(2025, 5, 9),
      location: 'BGC',
      category: 'shared',
    ),
    TravelPlan(
      title: 'Plan 6',
      date: DateTime(2025, 5, 15),
      location: 'Baguio',
      category: 'shared',
    ),
    TravelPlan(
      title: 'Plan 7',
      date: DateTime(2025, 4, 6),
      location: 'Ewan',
      category: 'done',
    ),
    TravelPlan(
      title: 'Plan 8',
      date: DateTime(2025, 4, 9),
      location: 'Dorm',
      category: 'done',
    ),
  ];

  TravelPlan currentlyAdding = TravelPlan(
    title: '',
    date: DateTime.now(),
    location: '',
    category: '',
  );
  TravelPlan selectedPlan = TravelPlan(
    title: '',
    date: DateTime.now(),
    location: '',
    category: '',
  );

  void setFilterCategory(String category) {
    planCategory = category;
    notifyListeners();
  }

  void setCurrentlyAdding(TravelPlan plan) {
    currentlyAdding = plan;
    notifyListeners();
  }

  void addPlan(TravelPlan plan) {
    allPlans.insert(0, plan);
    notifyListeners();
  }

  void setSelectedPlan(TravelPlan plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  void removePlan(String title) {
    allPlans.removeWhere((p) => p.title == title);
    notifyListeners();
  }

  void updatePlan(TravelPlan updatedPlan) {
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
