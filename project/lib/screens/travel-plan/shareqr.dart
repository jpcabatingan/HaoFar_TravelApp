// Share QR
// user can generate a qr code image of their plan and have another user sign it to share the plan details
// Added functionality to save QR code to phone's storage.

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:project/models/travel_plan.dart';
import 'package:project/providers/travel_plan_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareQR extends StatefulWidget {
  const ShareQR({super.key});

  @override
  State<ShareQR> createState() => _ShareQRState();
}

class _ShareQRState extends State<ShareQR> {
  final GlobalKey _qrImageKey = GlobalKey(); // Key to capture the QR image

  Future<void> _saveQrCode(BuildContext context, String planName) async {
    // 1. Request Storage Permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    // For Android 10 (API 29) and above, manage external storage might be needed for broader access
    // or rely on scoped storage if targeting newer APIs. ImageGallerySaver often handles this.
    // For iOS, photos permission is usually handled by the image_gallery_saver plugin via Info.plist.

    if (status.isGranted) {
      try {
        // 2. Capture the QR Image
        RenderRepaintBoundary boundary =
            _qrImageKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(
          pixelRatio: 3.0,
        ); // Higher pixelRatio for better quality
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // 3. Save the image
        // Sanitize planName for use as a filename
        final String sanitizedPlanName = planName
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .replaceAll(' ', '_');
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 90,
          name:
              "travel_plan_qr_${sanitizedPlanName}_${DateTime.now().millisecondsSinceEpoch}",
          isReturnImagePathOfIOS: true, // Required for iOS
        );

        if (context.mounted) {
          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'QR Code saved to Gallery: ${result["filePath"] ?? ""}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to save QR Code: ${result['errorMessage'] ?? 'Unknown error'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving QR Code: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        print("Error saving QR: $e");
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied. Cannot save QR Code.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      // Optionally, guide user to settings
      // openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final String? planId = arguments is String ? arguments : null;

    // Using watch here if the plan details might change while this screen is open,
    // otherwise read is fine if plan data is static once fetched for this screen.
    final provider = context.watch<TravelPlanProvider>();
    final dateFormatter = DateFormat.yMMMMd();

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
      stream: provider.getPlanStream(planId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Scaffold(
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

        final bool isCreator =
            plan.createdBy ==
            Provider.of<AuthProvider>(context, listen: false).user?.uid;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: const BackButton(color: Colors.black87),
            title: Text(
              'Share: ${plan.name}',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      plan.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
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
                    const SizedBox(height: 30),
                    RepaintBoundary(
                      // Wrap QrImageView with RepaintBoundary
                      key: _qrImageKey,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Colors
                                  .white, // Ensure background is not transparent for capture
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
                              planId, // The data for the QR code (e.g., plan ID or a URL)
                          version: QrVersions.auto,
                          size: 220.0,
                          gapless:
                              false, // Recommended to be false for better scanability
                          backgroundColor:
                              Colors.white, // Explicit background for QR
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          errorStateBuilder: (cxt, err) {
                            return const Center(
                              child: Text(
                                "Uh oh! Something went wrong generating the QR code.",
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isCreator
                          ? "Let others scan this code to join your travel plan!"
                          : "Scan this code to view plan details.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    // Save QR Code Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text("Save QR to Gallery"),
                      onPressed: () {
                        _saveQrCode(context, plan.name);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
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
