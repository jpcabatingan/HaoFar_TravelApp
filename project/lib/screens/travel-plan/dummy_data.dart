import 'package:project/models/travel_plan.dart';

List<TravelPlan> getDummyPlans() {
  return [
    TravelPlan(
      planId: "sample1",
      createdBy: "user123",
      name: "Paris Adventure",
      startDate: DateTime(2025, 6, 10),
      endDate: DateTime(2025, 6, 17),
      location: "Paris, France",
      additionalInfo: {},
      itinerary: [],
      sharedWith: [],
    ),
    TravelPlan(
      planId: "sample2",
      createdBy: "user456",
      name: "Tokyo Escapade",
      startDate: DateTime(2025, 7, 1),
      endDate: DateTime(2025, 7, 10),
      location: "Tokyo, Japan",
      additionalInfo: {},
      itinerary: [],
      sharedWith: ["user123"],
    ),
    TravelPlan(
      planId: "sample3",
      createdBy: "user789",
      name: "Bali Retreat",
      startDate: DateTime(2024, 12, 15),
      endDate: DateTime(2024, 12, 22),
      location: "Bali, Indonesia",
      additionalInfo: {},
      itinerary: [],
      sharedWith: [],
    ),
  ];
}
