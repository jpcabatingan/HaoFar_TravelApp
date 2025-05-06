import 'package:project/models/checklist_item.dart';

class TravelPlan {
  final String title;
  final DateTime date;
  final String location;
  final String category;

  final String? flight;
  final String? accommodation;
  final String? itinerary;
  final String? notes;
  final List<ChecklistItem>? checklist;

  TravelPlan({
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
