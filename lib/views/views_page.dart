import 'package:flutter/material.dart';
import 'package:robocontrol/controllers/settings_controller.dart';
import 'package:get/get.dart';

class ViewsPage extends StatelessWidget {
  const ViewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FractionallySizedBox(
            widthFactor: 0.8,
            child: TextField(
              controller: settingsController.streamIpController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.network_wifi),
                labelText: "Server IP Address",
                hintText: "Enter the server IP address",
                border: OutlineInputBorder(),
              ),
            ),
          ),
            SizedBox(height: 16.0),
          _buildStyledButton(
            onPressed: settingsController.launchStream,
            label: "Launch Robot View",
            icon: Icons.videocam,
            backgroundColor: const Color(0xFFBBDEFB),
          ),
          SizedBox(height: 16.0),
          _buildStyledButton(
            onPressed: settingsController.closeStream,
            label: "Close Robot View",
            icon: Icons.videocam_off,
            backgroundColor: const Color(0xFFFFF9C4),
          ),
          SizedBox(height: 16.0),
          _buildStyledButton(
            onPressed: settingsController.shutdown,
            label: "Shutdown",
            icon: Icons.power_settings_new,
            backgroundColor: const Color(0xFFFFCDD2),
          ),
          SizedBox(height: 16.0),
          _buildStyledButton(
            onPressed: settingsController.reboot,
            label: "Reboot",
            icon: Icons.refresh,
            backgroundColor: const Color(0xFFC8E6C9),
          ),
        ],
      ),
    );
  }
}

Widget _buildStyledButton({
  required VoidCallback onPressed,
  required String label,
  required IconData icon,
  required Color backgroundColor,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      fixedSize: Size(250, 55),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      side: BorderSide(color: Colors.grey.shade400),
    ),
    icon: Icon(icon, color: Colors.grey.shade800),
    label: Text(
      label,
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
