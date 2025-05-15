import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/app/routes.dart'; // Assuming AppRoutes.shareQR is defined

class PlanDetails extends StatelessWidget {
  const PlanDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final planId =
        ModalRoute.of(context)?.settings.arguments
            as String?; // Make planId nullable
    final provider = context.read<TravelPlanProvider>();

    final dateFormatter = DateFormat.yMMMMd();

    if (planId == null) {
      // Handle the case where planId is null, perhaps show an error or pop
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Travel plan ID is missing.")),
      );
    }

    return StreamBuilder<TravelPlan?>(
      stream: provider.getPlanStream(planId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final plan = snapshot.data;
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Not Found")),
            body: const Center(child: Text("Plan not found")),
          );
        }
        // Build UI with the fetched plan
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: Text(
              '${plan.name} Details',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("Start: ${dateFormatter.format(plan.startDate)}"),
                  Text("End: ${dateFormatter.format(plan.endDate)}"),
                  Text("Location: ${plan.location}"),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text("Generate QR Code"),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.shareQR, // Use named route from AppRoutes
                        arguments: plan.planId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Colors.blue, // Optional: style the button
                      // foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel('FLIGHT DETAILS'),
                  _infoBox(plan.flightDetails),

                  _sectionLabel('ACCOMMODATION'),
                  _infoBox(plan.accommodation),

                  _sectionLabel('ITINERARY'),
                  _buildItinerary(plan.itinerary),

                  _sectionLabel('OTHER NOTES'),
                  _buildNotes(plan.notes),

                  _sectionLabel('CHECKLIST'),
                  _buildChecklist(plan.checklist),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.travelListDetailsEdit, // Use named route
                            arguments: plan.planId,
                          );
                        },
                        child: const Text(
                          'Edit Details',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Confirm deletion
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Plan?'),
                                  content: const Text(
                                    'Are you sure you want to delete this travel plan? This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            try {
                              await provider.deletePlan(plan.planId);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Plan deleted successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(
                                  context,
                                ); // Go back to the previous screen
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to delete plan: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text(
                          'Delete Plan',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Added some bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(
      text.toUpperCase(), // Consistent styling
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12, // Adjusted for better hierarchy
        letterSpacing: 1.1, // Keep letter spacing for style
        color: Colors.black54, // Subtler color for section labels
      ),
    ),
  );

  Widget _infoBox(String content) {
    if (content.isEmpty) {
      return Container(
        // Consistent styling even when empty
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Slightly different background for empty
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          "Not specified",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          // Subtle shadow for depth
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ), // Improved line height
    );
  }

  Widget _buildItinerary(List<Map<String, dynamic>> itinerary) {
    if (itinerary.isEmpty)
      return _infoBox(
        "No itinerary items yet.",
      ); // Use _infoBox for consistency

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itinerary.length,
      itemBuilder: (context, index) {
        final day = itinerary[index];
        final activities = List<Map<String, dynamic>>.from(
          day['activities'] ?? [],
        );
        return Card(
          // Using Card for better visual separation
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1, // Subtle elevation
          child: ExpansionTile(
            title: Text(
              "Day ${day['day']}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children:
                activities.isEmpty
                    ? [
                      const ListTile(
                        title: Text("No activities for this day."),
                      ),
                    ]
                    : activities
                        .map(
                          (act) => ListTile(
                            leading: const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: Colors.green,
                            ), // Added icon
                            title: Text("${act['time']} - ${act['activity']}"),
                            dense: true,
                          ),
                        )
                        .toList(),
          ),
        );
      },
    );
  }

  Widget _buildNotes(List<String> notes) {
    if (notes.isEmpty) return _infoBox("No notes added."); // Use _infoBox
    return _infoBox(
      notes.map((note) => "• $note").join('\n'),
    ); // Join notes into a single string for the info box
  }

  Widget _buildChecklist(List<String> checklist) {
    if (checklist.isEmpty)
      return _infoBox("No checklist items."); // Use _infoBox

    // For checklist, it's better to list them out rather than join into one string
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            checklist
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      "☐ $item",
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
