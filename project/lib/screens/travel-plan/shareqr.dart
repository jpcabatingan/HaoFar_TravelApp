import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Package to display QR codes
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';

class ShareQR extends StatelessWidget {
  const ShareQR({super.key});

  @override
  Widget build(BuildContext context) {
    // Attempt to cast safely and handle potential null.
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final String? planId = arguments is String ? arguments : null;

    final provider = context.read<TravelPlanProvider>();
    final dateFormatter = DateFormat.yMMMMd(); // For formatting dates

    // Handle the case where planId might be null (e.g., if arguments are not passed correctly)
    if (planId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: const BackButton(color: Colors.black),
        ),
        body: const Center(child: Text('No Travel Plan ID provided.')),
      );
    }

    return StreamBuilder<TravelPlan?>(
      stream: provider.getPlanStream(planId), // Fetch the specific plan
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            // Return a full scaffold during loading for better UX
            appBar: AppBar(
              title: const Text('Loading...'),
              leading: const BackButton(color: Colors.black),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final plan = snapshot.data;

        if (plan == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Not Found'),
              leading: const BackButton(color: Colors.black),
            ),
            body: const Center(child: Text("Travel plan not found.")),
          );
        }

        // Main UI for displaying the plan details and the QR code
        return Scaffold(
          backgroundColor: const Color.fromARGB(
            255,
            245,
            245,
            245,
          ), // Light grey background
          appBar: AppBar(
            backgroundColor: Colors.white, // White app bar
            elevation: 1, // Subtle shadow
            leading: const BackButton(color: Colors.black87),
            title: Text(
              'Share: ${plan.name}', // More descriptive title
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0), // Increased padding
            child: Center(
              // Center the content
              child: SingleChildScrollView(
                // Ensure content is scrollable if it overflows
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center column content
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center items horizontally
                  children: [
                    Text(
                      plan.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26, // Larger font for plan name
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Location: ${plan.location}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Dates: ${dateFormatter.format(plan.startDate)} - ${dateFormatter.format(plan.endDate)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 30), // More space before QR code
                    // QR Code Generation and Display
                    Container(
                      padding: const EdgeInsets.all(
                        10,
                      ), // Padding around QR code
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data:
                            planId, // The data encoded in the QR code (the planId)
                        version:
                            QrVersions
                                .auto, // Automatically determines QR version
                        size: 220.0, // Size of the QR code image
                        gapless: false, // Whether to have a small border (gap)
                        errorStateBuilder: (cxt, err) {
                          // Handles errors during QR generation
                          return const Center(
                            child: Text(
                              "Uh oh! Something went wrong generating the QR code.",
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Scan this code to join the travel plan!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
