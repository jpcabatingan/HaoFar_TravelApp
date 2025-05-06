import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/screens/travel-plan/dummy_data.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/travel_plan_provider.dart';

class TravelPlans extends StatefulWidget {
  const TravelPlans({super.key});

  @override
  State<TravelPlans> createState() => _TravelPlansState();
}

class _TravelPlansState extends State<TravelPlans> {
  final Color _labelsColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _fieldColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _titleColor = const Color.fromARGB(255, 80, 78, 118);
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);
  final Color _cardMyColor = const Color.fromARGB(255, 241, 100, 46);
  final Color _textMyColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _cardSharedColor = const Color.fromARGB(255, 252, 221, 157);

  final formkey = GlobalKey<FormState>();
  final DateFormat _dateFormatter = DateFormat.yMMMMd();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TravelPlanProvider>();
    final filteredPlans = provider.filteredPlans;

    // Show dummy data only if provider has no plans and is not loading
    final List<TravelPlan> displayPlans =
        filteredPlans.isEmpty && !provider.isLoading
            ? getDummyPlans()
            : filteredPlans;

    final selectedCategory = provider.planCategory;
    final isDone = selectedCategory == "done";
    final isAll = selectedCategory == "none";

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.pushNamed(context, '/homepage'),
        ),
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
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                SizedBox(
                  width: 70,
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.black,
                      size: 40,
                    ),
                    onPressed: () {
                      // TODO: Navigate to create screen
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildCategoryChips(),
          const SizedBox(height: 8),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            Text("Error: ${provider.error}")
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (!isDone && getSoonPlans(displayPlans).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Soon!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...getSoonPlans(displayPlans).map(_buildPlanTile),
                    const SizedBox(height: 16),
                  ],
                  if (!isDone && getLaterPlans(displayPlans).isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      "Later...",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...getLaterPlans(displayPlans).map(_buildPlanTile),
                  ],
                  if (isDone || isAll) ...displayPlans.map(_buildPlanTile),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<TravelPlan> getSoonPlans(List<TravelPlan> plans) {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    return plans
        .where((p) => p.startDate.isAfter(now) && p.startDate.isBefore(soon))
        .toList();
  }

  List<TravelPlan> getLaterPlans(List<TravelPlan> plans) {
    final soon = DateTime.now().add(const Duration(days: 7));
    return plans.where((p) => p.startDate.isAfter(soon)).toList();
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    final isSelected = context.read<TravelPlanProvider>().planCategory == value;
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

  Widget _buildPlanTile(TravelPlan plan) {
    final startDateStr = _dateFormatter.format(plan.startDate);
    final endDateStr = _dateFormatter.format(plan.endDate);

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
                  plan.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Start: $startDateStr",
                  style: const TextStyle(fontSize: 12),
                ),
                Text("End: $endDateStr", style: const TextStyle(fontSize: 12)),
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
