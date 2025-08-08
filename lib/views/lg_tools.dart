import 'package:flutter/material.dart';
import 'package:robosim/controllers/settings_controller.dart';
import 'package:get/get.dart';

class LgTools extends StatelessWidget {
  const LgTools({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.find();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Zoom Section ---
          Text(
            'Zoom',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Column(
              children: [
                Slider(
                  value: settingsController.zoomLevel.value,
                  min: 1.0,
                  max: 5.0,
                  // No divisions for continuous float values
                  label: settingsController.zoomLevel.value.toStringAsFixed(1),
                  onChanged: (value) {
                    settingsController.zoomLevel.value = value;
                    settingsController.transmitZoomLevel();
                  },
                ),
                Text(
                  'Zoom Level: ${settingsController.zoomLevel.value.toStringAsFixed(1)}x',
                  // style: textTheme.labelLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // --- LG Tools Section ---
          Text(
            'LG Tools',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),
          Obx(() => SizedBox(
          width: double.infinity,
          child: _buildLgToolButton(
            // The logic inside here is ALREADY correct, it just needs to be rebuilt
            onPressed: settingsController.toggleSocketConnection,
            label: settingsController.isconnectedsocket.value 
                   ? 'Disconnect from Server' // Maybe change the text too
                   : 'Connect to Video Server',
            icon: Icons.wifi, 
            isDestructive: settingsController.isconnectedsocket.value
          ),
        )),
          const SizedBox(height: 16),
          // --- Button Grid ---
          Row(
            children: [
              Expanded(
                child: _buildLgToolButton(
                  onPressed: settingsController.launchStream,
                  label: 'Start Stream',
                  icon: Icons.video_call,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLgToolButton(
                  onPressed: settingsController.closeStream,
                  label: 'Close Stream',
                  icon: Icons.close,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLgToolButton(
                  onPressed: settingsController.showLogo,
                  label: 'Show Logo',
                  icon: Icons.visibility_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLgToolButton(
                  onPressed: settingsController.clearLogo,
                  label: 'Clear Logo',
                  icon: Icons.visibility_off_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLgToolButton(
                  onPressed: settingsController.reboot,
                  label: 'Reboot',
                  icon: Icons.refresh_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLgToolButton(
                  onPressed: settingsController.relaunch,
                  label: 'Relaunch',
                  icon: Icons.rocket_launch_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Full-width Shutdown Button ---
          SizedBox(
            width: double.infinity,
            child: _buildLgToolButton(
              onPressed: settingsController.shutdown,
              label: 'Shutdown',
              icon: Icons.power_settings_new_rounded,
              isDestructive:
                  true, // Use a different color for dangerous actions
            ),
          ),
        ],
      ),
    );
  }
}

/// A helper widget to create modern, sleek buttons for the LG Tools.
Widget _buildLgToolButton({
  required VoidCallback onPressed,
  required String label,
  required IconData icon,
  bool isDestructive = false,
}) {
  return FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: const Color.fromARGB(255, 34, 33, 33)),
    label: Text(label),
    style: FilledButton.styleFrom(
      // Use error color for destructive actions like shutdown
      backgroundColor:
          isDestructive
              ? const Color.fromARGB(255, 247, 111, 111)
              : const Color.fromARGB(255, 249, 171, 87),
      foregroundColor: const Color.fromARGB(255, 34, 33, 33),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
    ),
  );
}
