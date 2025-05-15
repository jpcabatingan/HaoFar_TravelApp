import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/auth_provider.dart'; // Required for current user ID
import 'package:project/screens/travel-plan/scanqr.dart';
import 'package:provider/provider.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/app/routes.dart'; // Assuming AppRoutes are defined
// Import the new QrScannerScreen (ensure the path is correct)

class TravelPlans extends StatefulWidget {
  const TravelPlans({super.key});

  @override
  State<TravelPlans> createState() => _TravelPlansState();
}

class _TravelPlansState extends State<TravelPlans> {
  final Color _btnAdd = const Color.fromARGB(255, 201, 238, 80);
  final DateFormat _dateFormatter =
      DateFormat.yMMMMd(); // Corrected initialization

  Future<void> _scanAndJoinPlan() async {
    // Navigate to the QrScannerScreen and wait for a result
    final String? scannedPlanId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (!mounted || scannedPlanId == null || scannedPlanId.isEmpty) {
      if (scannedPlanId != null && scannedPlanId.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scanned QR code was empty.")),
        );
      }
      return; // User cancelled or QR code was empty
    }

    final travelPlanProvider = context.read<TravelPlanProvider>();
    final authProvider = context.read<AuthProvider>();
    final String? currentUserId = authProvider.user?.uid;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to join a plan.")),
      );
      return;
    }

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Processing... Joining plan...")),
      );

      TravelPlan? planToJoin = await travelPlanProvider.getPlanById(
        scannedPlanId,
      );

      if (!mounted) return;

      if (planToJoin == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Travel plan not found.")));
        return;
      }

      if (planToJoin.createdBy == currentUserId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are the creator of this plan.")),
        );
        return;
      }

      if (planToJoin.sharedWith.contains(currentUserId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You are already part of this plan.")),
        );
        return;
      }

      // Add current user to sharedWith list
      final List<String> updatedSharedWith = List<String>.from(
        planToJoin.sharedWith,
      );
      updatedSharedWith.add(currentUserId);

      final TravelPlan updatedPlan = planToJoin.copyWith(
        sharedWith: updatedSharedWith,
      );

      await travelPlanProvider.updatePlan(updatedPlan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully joined '${planToJoin.name}'!"),
            backgroundColor: Colors.green,
          ),
        );
        travelPlanProvider.refresh(); // Refresh the list of plans
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to join plan: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TravelPlanProvider>();
    final filteredPlans = provider.filteredPlans;

    final selectedCategory = provider.planCategory;
    final isDone = selectedCategory == "done";
    // final isAll = selectedCategory == "none"; // Not used, can be removed

    final now = _getDateOnly(DateTime.now());
    final soon = now.add(const Duration(days: 7));

    // Filter out plans where the current user is the creator for "Soon" and "Later" if category is "shared"
    // This is to avoid showing plans created by the user in the "shared" soon/later sections.
    List<TravelPlan> relevantPlans = filteredPlans;
    if (selectedCategory == "shared") {
      final authProvider = context.read<AuthProvider>();
      final String? currentUserId = authProvider.user?.uid;
      if (currentUserId != null) {
        relevantPlans =
            filteredPlans.where((p) => p.createdBy != currentUserId).toList();
      }
    }

    final soonPlans = getSoonPlans(relevantPlans, now, soon);
    final laterPlans = getLaterPlans(relevantPlans, soon);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: RefreshIndicator(
        onRefresh: provider.refresh, // Simplified call
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
                          ? "Shared With Me"
                          : selectedCategory == "done"
                          ? "Completed Plans"
                          : "All My Plans",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  // Scan QR Code Button
                  IconButton(
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Color.fromARGB(255, 71, 70, 70),
                    ),
                    tooltip: 'Scan to Join Plan',
                    onPressed: _scanAndJoinPlan,
                  ),
                  const SizedBox(width: 8), // Spacing
                  FloatingActionButton.small(
                    backgroundColor: _btnAdd,
                    tooltip: 'Create New Plan',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.createTravelPlan,
                      ); // Use AppRoutes
                    },
                    child: const Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 71, 70, 70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildCategoryChips(),
            const SizedBox(height: 8),
            if (provider.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ) // Expanded for proper centering
            else if (provider.error != null)
              Expanded(
                // Expanded for proper centering
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Error: ${provider.error}\nPull down to refresh.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child:
                    filteredPlans.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              selectedCategory == "none"
                                  ? "No travel plans yet.\nTap '+' to create one or scan a QR code to join!"
                                  : selectedCategory == "my"
                                  ? "You haven't created any plans yet.\nTap '+' to get started!"
                                  : selectedCategory == "shared"
                                  ? "No plans have been shared with you yet.\nScan a QR code to join one."
                                  : selectedCategory == "done"
                                  ? "No completed plans."
                                  : "No travel plans in this category.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                        : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            if (!isDone && soonPlans.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text(
                                "Coming Up Soon!",
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
                                "Later Adventures",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...laterPlans.map((plan) => _buildPlanTile(plan)),
                              const SizedBox(height: 16),
                            ],
                            if (isDone && filteredPlans.isNotEmpty) ...[
                              // Show "Completed" header only if there are done plans
                              const SizedBox(height: 10),
                              const Text(
                                "Completed Trips",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...filteredPlans.map(
                                (plan) => _buildPlanTile(plan),
                              ),
                            ] else if (isDone && filteredPlans.isEmpty) ...[
                              // This case is handled by the main empty message now
                            ] else if (!isDone &&
                                soonPlans.isEmpty &&
                                laterPlans.isEmpty &&
                                filteredPlans.isNotEmpty) ...[
                              // If not 'done' and no soon/later plans, but there are plans (e.g. "all" or "my" with only past plans not yet 'done')
                              // This section will list them without "Soon" or "Later" headers.
                              // This might occur if 'done' filter logic is strictly by date and some past plans aren't yet categorized as 'done'
                              // or if 'all'/'my' categories contain only past plans.
                              ...filteredPlans.map(
                                (plan) => _buildPlanTile(plan),
                              ),
                            ],
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
        // Show plans starting today or in the next 7 days, but not past end date
        return (planDate.isAtSameMomentAs(now) || planDate.isAfter(now)) &&
            planDate.isBefore(soon) &&
            !_getDateOnly(p.endDate).isBefore(now);
      }).toList()
      ..sort(
        (a, b) => a.startDate.compareTo(b.startDate),
      ); // Sort by start date
  }

  List<TravelPlan> getLaterPlans(List<TravelPlan> plans, DateTime soon) {
    final now = _getDateOnly(DateTime.now());
    return plans.where((p) {
        final planDate = _getDateOnly(p.startDate);
        // Show plans starting on or after 'soon' date, and not past end date
        return planDate.isAtSameOrAfter(soon) &&
            !_getDateOnly(p.endDate).isBefore(now);
      }).toList()
      ..sort(
        (a, b) => a.startDate.compareTo(b.startDate),
      ); // Sort by start date
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4, // Added runSpacing for better layout on smaller screens
        children: [
          _chipButton("All My Plans", "none", Colors.blueAccent),
          _chipButton("My Created", "my", Colors.teal),
          _chipButton("Shared With Me", "shared", Colors.orange),
          _chipButton("Completed", "done", Colors.purple),
        ],
      ),
    );
  }

  Widget _chipButton(String label, String value, Color activeColor) {
    final provider =
        context.read<TravelPlanProvider>(); // Use read here as it's for action
    final isSelected = provider.planCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.setFilterCategory(value),
      selectedColor: activeColor.withOpacity(0.25),
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? activeColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // More rounded
        side: BorderSide(color: isSelected ? activeColor : Colors.grey[400]!),
      ),
      elevation: isSelected ? 2 : 0,
      pressElevation: 4,
    );
  }

  Widget _buildPlanTile(TravelPlan plan) {
    final startDateStr = _dateFormatter.format(plan.startDate);
    final endDateStr = _dateFormatter.format(plan.endDate);
    final bool isCreator =
        context.read<AuthProvider>().user?.uid == plan.createdBy;

    return Card(
      // Using Card for a nicer look
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // InkWell for tap effect
        borderRadius: BorderRadius.circular(12),
        key: Key(plan.planId),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.travelListDetails, // Use AppRoutes
            arguments: plan.planId,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                // Placeholder for an image or icon
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors
                      .primaries[plan.name.hashCode % Colors.primaries.length]
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.explore_outlined, // More thematic icon
                  size: 30,
                  color:
                      Colors.primaries[plan.name.hashCode %
                          Colors.primaries.length],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.location,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$startDateStr - $endDateStr",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (!isCreator &&
                        plan.sharedWith.contains(
                          context.read<AuthProvider>().user?.uid,
                        ))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Shared with you",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
