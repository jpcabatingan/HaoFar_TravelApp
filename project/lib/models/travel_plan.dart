class TravelPlanModel {
  final String title;
  final DateTime date;
  final String location;
  final String category;

  final String? flight;
  final String? accommodation;
  final String? itinerary;
  final String? notes;
  final List<String>? checklist;

  TravelPlanModel({
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    this.flight,
    this.accommodation,
    this.itinerary,
    this.notes,
    this.checklist,
  });
}
