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
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareQR extends StatefulWidget {
  const ShareQR({super.key});

  @override
  State<ShareQR> createState() => _ShareQRState();
}

class _ShareQRState extends State<ShareQR> {
  final GlobalKey _qrImageKey = GlobalKey();

  Future<void> _saveQrCode(BuildContext context, String planName) async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      try {
        RenderRepaintBoundary boundary =
            _qrImageKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(
          pixelRatio: 3.0,
        );
        ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        final String sanitizedPlanName = planName
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .replaceAll(' ', '_');
        final result = await ImageGallerySaverPlus.saveImage(
          pngBytes,
          quality: 90, 
          name:
              "travel_plan_qr_${sanitizedPlanName}_${DateTime.now().millisecondsSinceEpoch}",
          isReturnImagePathOfIOS: true,
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
            content: Text('Photos permission denied. Cannot save QR Code.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final String? planId = arguments is String ? arguments : null;

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
                      key: _qrImageKey,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Colors.white,
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
                              planId,
                          version: QrVersions.auto,
                          size: 220.0,
                          gapless:
                              false,
                          backgroundColor:
                              Colors.white,
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