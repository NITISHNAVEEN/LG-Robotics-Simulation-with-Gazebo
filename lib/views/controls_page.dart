import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controls_logic.dart';

class ControlsPage extends StatelessWidget {
  ControlsPage({super.key});
  final controller = Get.put(ControlsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Robot Joint Controller"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildConnectionCard(),
            const SizedBox(height: 24),
            _buildJointControllerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: controller.isConnected.value ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    controller.isConnected.value ? "Connected" : "Disconnected",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (controller.isConnecting.value)
                    const CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isConnected.value || controller.isConnecting.value
                          ? null
                          : controller.connectWebSocket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(controller.isConnecting.value ? "Connecting..." : "Connect"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isConnected.value ? controller.disconnectWebSocket : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Disconnect"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildJointControllerCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Joint Positions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ...controller.jointPositions.keys.map((joint) {
                final limits = controller.jointLimits[joint]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(joint.replaceAll("_", " "),
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text("${controller.jointPositions[joint]!.value.toStringAsFixed(2)} rad",
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Slider(
                        value: controller.jointPositions[joint]!.value,
                        min: limits[0],
                        max: limits[1],
                        onChanged: (val) => controller.updateJoint(joint, val),
                      ),
                    ],
                  ),
                );
              }).toList(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.resetAll,
                      child: const Text("Reset All"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.isConnected.value ? controller.sendJointPositions : null,
                      child: const Text("Send to Robot"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Continuous Mode"),
                  Obx(() => Switch(
                        value: controller.continuousMode.value,
                        onChanged: (val) => controller.continuousMode.value = val,
                      ),),
                ],
              )
            ],
          ),
        ));
  }
}
