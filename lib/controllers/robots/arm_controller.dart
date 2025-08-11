import 'package:get/get.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:robosim/controllers/controls.dart'; // Import joystick package

class ArmController extends GetxController {
  final ControlsController controlsController = Get.find();
  double rotVel = 0.0;
  double length = 0.0;
  double height = 0.0;
  double gripper = 0.0;

  void onRotationChanged(StickDragDetails details, String address) {
      // You can implement your logic here.
      // For example, sending data through the WebSocket.
      // double x = details.x;
      // double y = details.y;
      // if (x == 0.0 && y == 0.0) return;
      // rotVel = atan2(x, -y);
      // print('Joystick 1: x=${x.toStringAsFixed(2)}, y=${y.toStringAsFixed(2)}, rotVel=${rotVel.toStringAsFixed(2)}');
      rotVel = details.x;
      print('Joystick 1: x=${rotVel.toStringAsFixed(2)}');
      controlsController.sendJointPositions("/joystick_jacobian", [rotVel, length, -height, gripper]);
      // Example: sendDataToRobot('j1:${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}');
    }

    /// Handles data from the second joystick.
    /// `details.x` and `details.y` range from -1.0 to 1.0.
    void onPositionChanged(StickDragDetails details) {
      // You can implement your logic here.
      length = details.x;
      height = details.y;
      // if (x == 0.0 && y == 0.0) return;
      controlsController.sendJointPositions("/joystick_jacobian", [rotVel, length, -height, gripper]);
      print('Joystick 2: x=${length.toStringAsFixed(2)}, y=${height.toStringAsFixed(2)}');
      // Example: sendDataToRobot('j2:${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}');
    }

    void onGripped() {
      gripper = 0.22;
      controlsController.sendJointPositions("/joystick_jacobian", [rotVel, length, -height, gripper]);
    }

    void onReleased() {
      gripper = 0.7;
      controlsController.sendJointPositions("/joystick_jacobian", [rotVel, length, -height, gripper]);
    }
}