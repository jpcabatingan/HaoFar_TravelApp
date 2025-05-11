import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';

class PlanDetails extends StatelessWidget {
  const PlanDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final planId = ModalRoute.of(context)?.settings.arguments as String;
    final provider = context.read<TravelPlanProvider>();

    final dateFormatter = DateFormat.yMMMMd();

    return StreamBuilder<TravelPlan?>(
      stream: provider.getPlanStream(planId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final plan = snapshot.data;
        if (plan == null) {
          return const Scaffold(body: Center(child: Text("Plan not found")));
        }
        // Build UI with the fetched plan
        return Scaffold(
          backgroundColor: const Color(0xFFF6EEF8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6EEF8),
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
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/travel-list-details-edit',
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
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        try {
                          await provider.deletePlan(plan.planId);
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to delete plan: $e"),
                            ),
                          );
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
                  ),
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
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 1.1,
      ),
    ),
  );

  Widget _infoBox(String content) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.black12),
    ),
    child: Text(content, style: const TextStyle(fontSize: 14)),
  );

  Widget _buildItinerary(List<Map<String, dynamic>> itinerary) {
    return itinerary.isEmpty
        ? const Text("No itinerary items.")
        : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itinerary.length,
          itemBuilder: (context, index) {
            final day = itinerary[index];
            final activities = List<Map<String, dynamic>>.from(
              day['activities'] ?? [],
            );
            return ExpansionTile(
              title: Text("Day ${day['day']}"),
              children:
                  activities
                      .map(
                        (act) => ListTile(
                          title: Text("${act['time']} - ${act['activity']}"),
                        ),
                      )
                      .toList(),
            );
          },
        );
  }

  Widget _buildNotes(List<String> notes) {
    if (notes.isEmpty) return const Text("No notes.");
    return Column(children: notes.map((note) => Text("• $note")).toList());
  }

  Widget _buildChecklist(List<String> checklist) {
    if (checklist.isEmpty) return const Text("No checklist items.");
    return Column(
      children:
          checklist.map((item) => ListTile(title: Text("☐ $item"))).toList(),
    );
  }
}
