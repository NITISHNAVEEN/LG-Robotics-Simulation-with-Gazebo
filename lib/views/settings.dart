import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import 'qr_scan_view.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30.0),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const QRWidget());
                  },
                  style: ElevatedButton.styleFrom(
                    shape:
                        const CircleBorder(), // Makes the button perfectly circular
                    padding: const EdgeInsets.all(
                      24,
                    ), // Large padding to increase the size
                    backgroundColor:
                        Colors.blue.shade50, // A very light, subtle background
                    foregroundColor: Colors.blue.shade800, // Color for the icon
                    elevation: 2, // A very minimal shadow
                    shadowColor: Colors.blue.shade100,
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, size: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  "Scan to Connect",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
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
                          color:Colors.grey.shade700,
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
                      settingsController.sshConnected.value
                          ? settingsController.disconnect()
                          : settingsController.connectLg();
                    },
                    style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(5.0),
                      backgroundColor: WidgetStateProperty.all(
                        settingsController.sshConnected.value
                            ? const Color.fromARGB(255, 247, 111, 111)
                            : const Color.fromARGB(255, 249, 171, 87),
                      ),
                      side: WidgetStateProperty.all(BorderSide(width: 0.0)),
                      foregroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 46, 46, 46),
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
