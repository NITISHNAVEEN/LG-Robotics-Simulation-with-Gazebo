import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:robosim/controllers/controls.dart'; // Import joystick package

class AmigaController extends GetxController {
  final ControlsController controlsController = Get.find();

  void onDriveChanged(StickDragDetails details) {
      // You can implement your logic here.
      // For example, sending data through the WebSocket.
      double x = details.x;
      double y = details.y;
      print('Joystick 1: x=${x.toStringAsFixed(2)}, y=${y.toStringAsFixed(2)}');
      controlsController.sendJointPositions("/joystick_vel", [x,y]);
      // Example: sendDataToRobot('j1:${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}');
    }

}