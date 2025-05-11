import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/travel_plan.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/travel_plan_provider.dart';

class TravelPlans extends StatefulWidget {
  const TravelPlans({super.key});

  @override
  State<TravelPlans> createState() => _TravelPlansState();
}

class _TravelPlansState extends State<TravelPlans> {
  final Color _btnColorContinue = const Color.fromARGB(255, 163, 181, 101);
  final DateFormat _dateFormatter = DateFormat.yMMMMd();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TravelPlanProvider>();
    final filteredPlans = provider.filteredPlans;

    final selectedCategory = provider.planCategory;
    final isDone = selectedCategory == "done";
    final isAll = selectedCategory == "none";

    final now = _getDateOnly(DateTime.now());
    final soon = now.add(const Duration(days: 7));

    final soonPlans = getSoonPlans(filteredPlans, now, soon);
    final laterPlans = getLaterPlans(filteredPlans, soon);

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      body: RefreshIndicator(
        onRefresh: () async {
          provider.refresh();
        },
        child: Column(
          children: [
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
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
                  FloatingActionButton.small(
                    backgroundColor: _btnColorContinue,
                    onPressed: () {
                      Navigator.pushNamed(context, '/new-travel-list');
                    },
                    child: const Icon(Icons.add),
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
              Center(
                child: Text(
                  "Error: ${provider.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Expanded(
                child:
                    filteredPlans.isEmpty
                        ? const Center(
                          child: Text(
                            "No travel plans found. Tap '+' to add one.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        )
                        : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (!isDone && soonPlans.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text(
                                "Soon!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...soonPlans.map((plan) => _buildPlanTile(plan)),
                              const SizedBox(height: 16),
                            ],
                            if (!isDone && laterPlans.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text(
                                "Later...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...laterPlans.map((plan) => _buildPlanTile(plan)),
                            ],
                            // Changed condition: Only show flat list for "Done" category
                            if (isDone)
                              ...filteredPlans.map(
                                (plan) => _buildPlanTile(plan),
                              ),
                          ],
                        ),
              ),
          ],
        ),
      ),
    );
  }

  List<TravelPlan> getSoonPlans(
    List<TravelPlan> plans,
    DateTime now,
    DateTime soon,
  ) {
    return plans.where((p) {
      final planDate = _getDateOnly(p.startDate);
      return planDate.isAfter(now) && planDate.isBefore(soon);
    }).toList();
  }

  List<TravelPlan> getLaterPlans(List<TravelPlan> plans, DateTime soon) {
    return plans.where((p) {
      final planDate = _getDateOnly(p.startDate);
      return planDate.isAtSameOrAfter(soon);
    }).toList();
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

    return GestureDetector(
      key: Key(plan.planId), // ✅ Unique key to avoid Flutter widget reuse bugs
      onTap: () {
        Navigator.pushNamed(
          context,
          '/travel-list-details',
          arguments: plan.planId, // Pass ID instead of the entire plan
        );
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
                    plan.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Start: $startDateStr",
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "End: $endDateStr",
                    style: const TextStyle(fontSize: 12),
                  ),
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

  DateTime _getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
