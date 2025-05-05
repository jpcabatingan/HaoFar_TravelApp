import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TravelPlan {
  final String title;
  final DateTime date;
  final String location;
  final String category;

  TravelPlan({
    required this.title,
    required this.date,
    required this.location,
    required this.category,
  });
}

class TravelPlans extends StatefulWidget {
  const TravelPlans({super.key});

  @override
  State<TravelPlans> createState() => _TravelPlansState();
}

class _TravelPlansState extends State<TravelPlans> {
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);

  final Color _cardMyColor = const Color.fromARGB(255, 241, 100, 46);
  final Color _textMyColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _cardSharedColor = const Color.fromARGB(255, 252, 221, 157);

  final formkey = GlobalKey<FormState>();
  String selectedCategory = "my";

  final List<TravelPlan> allPlans = [
    TravelPlan(
      title: 'Plan 1',
      date: DateTime(2025, 5, 6),
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
      date: DateTime(2025, 5, 6),
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

  List<TravelPlan> getFilteredPlans(String category) {
    return allPlans.where((plan) => plan.category == category).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<TravelPlan> getSoonPlans(List<TravelPlan> plans) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    return plans
        .where((p) => p.date.isAfter(now) && p.date.isBefore(soon))
        .toList();
  }

  List<TravelPlan> getLaterPlans(List<TravelPlan> plans) {
    final soon = DateTime.now().add(const Duration(days: 7));
    return plans.where((p) => p.date.isAfter(soon)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _createBody(context));
  }

  Widget _createBody(BuildContext context) {
    final filteredPlans = getFilteredPlans(selectedCategory);
    final isDone = selectedCategory == "done";

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        leading: BackButton(color: Colors.black, onPressed: () => Navigator.pushNamed(context, '/homepage'),),
        title: const Text(
          'Traveler',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 25,),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                    selectedCategory == "my"
                        ? "My Plans"
                        : selectedCategory == "shared"
                        ? "Shared with me"
                        : "Done",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          _buildCategoryChips(),
          const SizedBox(height: 8),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (!isDone && getSoonPlans(filteredPlans).isNotEmpty) ...[
                  SizedBox(height: 10,),
                  const Text(
                    "Soon!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...getSoonPlans(filteredPlans).map(_buildPlanTile),
                  const SizedBox(height: 16),
                ],
                if (!isDone && getLaterPlans(filteredPlans).isNotEmpty) ...[
                  SizedBox(height: 10,),
                  const Text(
                    "Later...",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...getLaterPlans(filteredPlans).map(_buildPlanTile),
                ],
                if (isDone) ...filteredPlans.map(_buildPlanTile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          _chipButton("My Plans", "my", Colors.green),
          _chipButton("Shared with me", "shared", Colors.green),
          _chipButton("Done", "done", Colors.red),
        ],
      ),
    );
  }

  Widget _chipButton(String label, String value, Color activeColor) {
    final isSelected = selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => selectedCategory = value),
      selectedColor: activeColor.withOpacity(0.2),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildPlanTile(TravelPlan plan) {
    final dateStr = DateFormat.yMMMMd().format(plan.date);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.image, size: 48, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text("Date: $dateStr", style: const TextStyle(fontSize: 12)),
                Text(
                  "Location: ${plan.location}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
