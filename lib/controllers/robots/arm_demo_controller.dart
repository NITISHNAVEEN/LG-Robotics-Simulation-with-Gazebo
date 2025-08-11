import 'package:get/get.dart';
import 'package:robosim/controllers/controls.dart'; // Import joystick package

class ArmDemoController extends GetxController {
  final ControlsController controlsController = Get.find();
  double angle = 0.0;
  double length = 0.0;
  double height = 0.0;
  double gripper = 0.0;

    void runDemo() {
      controlsController.sendOrder();
    }
}