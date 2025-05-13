import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';

class ShareQR extends StatelessWidget {
  const ShareQR({super.key});

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
                  const SizedBox(height: 20),

                  // QR Code Generation
                  Center(
                    child: QrImageView(
                      data: planId, // or any encoded data you want
                      version: QrVersions.auto,
                      size: 200.0,
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
}
