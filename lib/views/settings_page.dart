import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robocontrol/controllers/settings_controller.dart';
import 'package:robocontrol/views/qr_scan_view.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30.0),
          Center(
            child: OutlinedButton(
              onPressed: () {
                Get.to(() => const AlternativeQRWidget());
              },
              style: ButtonStyle(
                elevation: const WidgetStatePropertyAll(5.0),
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 112, 200, 255),
                ),
                side: WidgetStateProperty.all(BorderSide(width: 0.0)),
                foregroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 48, 48, 48),
                ),
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
          // const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Obx(
              () => Column(
                children: [
                  // Text(
                  //   settingsController.qrCode.isEmpty
                  //       ? "No QR Data available"
                  //       : "Scanned QR: ${settingsController.qrCode.value}",
                  //   style: const TextStyle(fontSize: 20.0),
                  // ),
                  SizedBox(height: 15.0),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 8.0), // Leading space
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color:
                              settingsController.sshConnected.value
                                  ? Colors.green
                                  : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 10.0), // Space between dot and text
                      Text(
                        settingsController.sshConnected.value
                            ? "Connected"
                            : "Not Connected",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color:
                              settingsController.sshConnected.value
                                  ? Colors.green.shade800
                                  : Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(width: 8.0), // Trailing space
                    ],
                  ),
                  SizedBox(height: 15.0),
                  TextField(
                    controller: settingsController.ipController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.computer),
                      labelText: 'IP address',
                      hintText: 'Enter Master IP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: settingsController.usernameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'LG Username',
                      hintText: 'Enter your username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: settingsController.passwordController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'LG Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: settingsController.sshPortController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.settings_ethernet),
                      labelText: 'SSH Port',
                      hintText: '22',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: settingsController.rigsController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.memory),
                      labelText: 'No. of LG rigs',
                      hintText: 'Enter the number of rigs',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      // settingsController.sshConnected.value=(settingsController.sshConnected.value)?false:true;
                      settingsController.sshConnected.value ? settingsController.disconnect():settingsController.connectLg();
                    },
                    style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(5.0),
                      backgroundColor: WidgetStateProperty.all(
                        settingsController.sshConnected.value ?Color.fromARGB(255, 250, 67, 67): Color.fromARGB(255, 34, 172, 10),
                      ),
                      side: WidgetStateProperty.all(BorderSide(width: 0.0)),
                      foregroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 242, 242, 242),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Text(
                      settingsController.sshConnected.value
                          ? "Disconnect"
                          : "Connect",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
