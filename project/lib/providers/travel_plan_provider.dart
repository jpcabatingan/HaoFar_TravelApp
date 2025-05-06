import 'package:flutter/widgets.dart';

class TravelPlanProvider with ChangeNotifier {
  String planCategory = "none";

  // setting selected mood to be read by mood_details
  void setFilterCategory(String category) {
    planCategory = category;
    notifyListeners();
  }
}

// context.read<TravelPlanProvider>().setFilterCategory("");

