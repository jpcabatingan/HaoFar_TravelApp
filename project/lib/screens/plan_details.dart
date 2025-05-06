import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:project/models/travel_plan.dart';

class PlanDetails extends StatelessWidget {
  const PlanDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final TravelPlanModel plan =
        context.watch<TravelPlanProvider>().selectedPlan!;
    final dateStr = DateFormat.yMMMMd().format(plan.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF6EEF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EEF8),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Traveler',
          style: TextStyle(
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
                plan.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("Date: $dateStr", style: const TextStyle(fontSize: 14)),
              Text(
                "Location: ${plan.location}",
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              _sectionLabel('FLIGHT DETAILS'),
              _infoBox(plan.flight),

              _sectionLabel('ACCOMMODATION'),
              _infoBox(plan.accommodation),

              _sectionLabel('ITINERARY'),
              _infoBox(plan.itinerary),

              _sectionLabel('OTHER NOTES'),
              _infoBox(plan.notes),

              _sectionLabel('CHECKLIST'),
              Column(
                children:
                    plan.checklist?.map((item) {
                      return Row(
                        children: [
                          Checkbox(
                            value: item.isChecked,
                            onChanged: null,
                          ),
                          Expanded(child: Text(item.text)),
                        ],
                      );
                    }).toList() ??
                    [const Text("No checklist items.")],
              ),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    print("Want to edit");
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
                  onPressed: () {
                    print("Delete Plan");
                    context.read<TravelPlanProvider>().removePlan(plan.title);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Delete Plan',
                    style: TextStyle(
                      color: Colors.blue,
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

  Widget _infoBox(String? content) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.black12),
    ),
    child: Text(content ?? '', style: const TextStyle(fontSize: 14)),
  );
}
