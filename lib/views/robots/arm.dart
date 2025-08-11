import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robosim/controllers/controls.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:robosim/controllers/robots/arm_controller.dart';

class ArmExp extends StatelessWidget {
  const ArmExp({super.key});

  @override
  Widget build(BuildContext context) {
    final ControlsController controlsController = Get.find();
    final ArmController armController = Get.find();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Description',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 216, 216, 216),
            ),
            child: const Center(
              child: Text(
                "The SO-ARM-100, is an open-source robotic arm developed by The Robot Studio in collaboration with Hugging Face. It's designed to be low-cost and accessible, primarily using 3D-printed parts. This is an interactive Liquid Galaxy Simulation for the same.",
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 22, 24, 26),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildConnectionHeader(controlsController),
          const Divider(),
          const SizedBox(height: 8),
          _buildInputAndConnectRow(controlsController),
          const SizedBox(height: 16),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              'Joystick',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const Divider(),
          // const SizedBox(height: 12),
          _buildJoystickControls(armController),
        ],
      ),
    );
  }

  Widget _buildConnectionHeader(ControlsController controlsController) {
    return Row(
      children: [
        Text(
          'Connection',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const Spacer(), // Pushes the status dot to the far right
        Obx(
          () => CircleAvatar(
            radius: 8,
            backgroundColor:
                controlsController.isConnected.value
                    ? Colors.green.shade600
                    : Colors.red.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInputAndConnectRow(ControlsController controlsController) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The TextField now takes up all available space
        Expanded(
          child: TextField(
            controller: controlsController.textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "IP address",
              hintText: "Enter your IP",
              prefixText: "ws://",
              suffixText: ":9090",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // The button logic is extracted and placed here
        _buildConnectButton(controlsController),
      ],
    );
  }

  Widget _buildConnectButton(ControlsController controlsController) {
    return Obx(
      () => FilledButton.icon(
        onPressed:
            controlsController.isConnecting.value
                ? null // Disable button while connecting
                : () {
                  if (controlsController.isConnected.value) {
                    controlsController.disconnectWebSocket();
                  } else {
                    // Unfocus the text field before connecting
                    FocusManager.instance.primaryFocus?.unfocus();
                    controlsController.connectWebSocket();
                  }
                },
        icon:
            controlsController.isConnecting.value
                ? Container() // No icon when loading
                : Icon(
                  controlsController.isConnected.value
                      ? Icons.link_off_rounded
                      : Icons.link_rounded,
                  color: const Color.fromARGB(255, 41, 41, 41),
                ),
        label:
            controlsController.isConnecting.value
                ? const SizedBox(
                  height: 12,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                : Text(
                  controlsController.isConnected.value
                      ? "Disconnect"
                      : "Connect",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 41, 41, 41),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        style: FilledButton.styleFrom(
          // Adjusted padding to better align with the text field height
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          backgroundColor:
              controlsController.isConnected.value
                  ? const Color.fromARGB(255, 247, 111, 111)
                  : const Color.fromARGB(255, 249, 171, 87),
          disabledBackgroundColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildJoystickControls(ArmController armController) {
    const joystickSize = 120.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Joystick
          Column(
            children: [
              SizedBox(
                height: joystickSize,
                width: joystickSize,
                child: Joystick(
                  // listener: (details) => controlsController.onJoystick1Changed(details),
                  listener:
                      (details) =>
                          armController.onRotationChanged(details, "10.0.2.2"),
                  // Optional: Custom styling
                  base: JoystickBase(
                    decoration: JoystickBaseDecoration(
                      color: Color.fromARGB(255, 73, 72, 72),
                      outerCircleColor: Color.fromARGB(255, 99, 65, 248),
                      // boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    arrowsDecoration: JoystickArrowsDecoration(
                      color: Color.fromARGB(255, 239, 237, 237),
                      enableAnimation: false,
                    ),
                  ),
                  stick: JoystickStick(
                    decoration: JoystickStickDecoration(
                      color: Color.fromARGB(255, 248, 169, 65),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Rotation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),

          // Gripper Button
          // _buildGripperButton(controlsController),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGripperButton('Grip', armController.onGripped),
              const SizedBox(height: 16),
              _buildGripperButton('Release', armController.onReleased),
            ],
          ),

          // Right Joystick
          Column(
            children: [
              SizedBox(
                height: joystickSize,
                width: joystickSize,
                child: Joystick(
                  // listener: (details) => controlsController.onJoystick2Changed(details),
                  listener:
                      (details) => armController.onPositionChanged(details),
                  base: JoystickBase(
                    decoration: JoystickBaseDecoration(
                      color: Color.fromARGB(255, 73, 72, 72),
                      outerCircleColor: Color.fromARGB(255, 248, 65, 65),
                      // boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    arrowsDecoration: JoystickArrowsDecoration(
                      color: Color.fromARGB(255, 239, 237, 237),
                      enableAnimation: false,
                    ),
                  ),
                  stick: JoystickStick(
                    decoration: JoystickStickDecoration(
                      color: Color.fromARGB(255, 248, 169, 65),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Position',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the circular button for the gripper.
  // Widget _buildGripperButton(ControlsController controlsController) {
  //   // return Obx(() =>
  //      return SizedBox(
  //       height: 80,
  //       width: 80,
  //       child: FloatingActionButton(
  //         // onPressed: () => controlsController.toggleGripper(),
  //         onPressed: () => {},
  //         // backgroundColor: controlsController.isGripperClosed.value
  //         //     ? const Color.fromARGB(255, 247, 111, 111) // "Closed" color
  //         //     : const Color.fromARGB(255, 111, 247, 139), // "Open" color
  //         backgroundColor: const Color.fromARGB(255, 111, 247, 139),
  //         child: Text(
  //           // controlsController.isGripperClosed.value ? 'Release' : 'Grip',
  //           'Grip',
  //           textAlign: TextAlign.center,
  //           style: const TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Color.fromARGB(255, 41, 41, 41),
  //           ),
  //         ),
  //       ),
  //     // ),
  //   );
  // }

  Widget _buildGripperButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 80,
      width: 80,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: const Color.fromARGB(255, 247, 209, 111),
        shape: const CircleBorder(),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 41, 41, 41),
          ),
        ),
      ),
    );
  }
}
