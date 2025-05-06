// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart' as authprov;
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/models/travel_plan.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String get selectedCategory =>
      context.watch<TravelPlanProvider>().planCategory;
  //  app colors
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);

  final Color _cardMyColor = const Color.fromARGB(255, 241, 100, 46);
  final Color _textMyColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _cardSharedColor = const Color.fromARGB(255, 252, 221, 157);

  final formkey = GlobalKey<FormState>();

  late final allPlans = context.watch<TravelPlanProvider>().allPlans;

  List<TravelPlanModel> getFilteredPlans(String category) {
    if (category == 'none') {
      return List<TravelPlanModel>.from(allPlans)
        ..sort((a, b) => a.date.compareTo(b.date));
    }
    return allPlans.where((plan) => plan.category == category).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<TravelPlanModel> getSoonPlans(List<TravelPlanModel> plans) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    return plans
        .where((p) => p.date.isAfter(now) && p.date.isBefore(soon))
        .toList();
  }

  List<TravelPlanModel> getLaterPlans(List<TravelPlanModel> plans) {
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
    final isAll = selectedCategory == "none";
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/newPlan');
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        title: const Text(
          'HaoFar Can I Go',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Hey there, JC!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.grey),
                child: Stack(
                  children: const [
                    Center(
                      child: Icon(Icons.image, size: 80, color: Colors.white70),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        'Top HaoLiday Destinations in 2025',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Text(
                      selectedCategory == "my"
                          ? "My Plans"
                          : selectedCategory == "shared"
                          ? "Shared with me"
                          : selectedCategory == "done"
                          ? "Done"
                          : "All Plans",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildCategoryChips(),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDone && getSoonPlans(filteredPlans).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Soon!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  ...getSoonPlans(filteredPlans).map(_buildPlanTile),
                  const SizedBox(height: 16),
                ],
                if (!isDone && getLaterPlans(filteredPlans).isNotEmpty) ...[
                  const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Wrap(
        spacing: 8,
        children: [
          _chipButton("All", "none", Colors.blue),
          _chipButton("My Plans", "my", Colors.green),
          _chipButton("Shared", "shared", Colors.green),
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
      onSelected:
          (_) => context.read<TravelPlanProvider>().setFilterCategory(value),
      selectedColor: isSelected ? activeColor.withOpacity(0.2) : null,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildPlanTile(TravelPlanModel plan) {
    final dateStr = DateFormat.yMMMMd().format(plan.date);
    return GestureDetector(
      onTap: () {
        context.read<TravelPlanProvider>().setSelectedPlan(plan);
        Navigator.pushNamed(context, '/planDetails');

        print("${plan.title} selected");
      },
      child: Container(
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
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.1,
      ),
    ),
  );
}
