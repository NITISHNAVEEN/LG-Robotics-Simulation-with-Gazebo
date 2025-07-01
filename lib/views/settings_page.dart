import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robocontrol/controllers/qr_controller.dart';
import 'package:robocontrol/views/qr_scan_view.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final qrController = Get.put(QRController());

    return Column(
      children: [
        const SizedBox(height: 30.0),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => const AlternativeQRWidget());
            },
            style: ButtonStyle(
              elevation: const WidgetStatePropertyAll(5.0),
              backgroundColor: WidgetStateProperty.all(
                const Color.fromARGB(255, 112, 200, 255),
              ),
              foregroundColor: WidgetStateProperty.all(Colors.black),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            child: const Text(
              "Scan your LG Rig QR Code",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        ),
        const SizedBox(height: 30.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => Text(
                qrController.qrCode.isEmpty
                    ? "No QR Data available"
                    : "Scanned QR: ${qrController.qrCode.value}",
                style: const TextStyle(fontSize: 20.0),
              )),
        ),
      ],
    );
  }
}
