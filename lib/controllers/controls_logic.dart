import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ControlsController extends GetxController {
  final isConnected = false.obs;
  final isConnecting = false.obs;
  final continuousMode = false.obs;
  final textController = TextEditingController();
  final getIp = GetStorage();

  // void submitText() {
  //   FocusManager.instance.primaryFocus?.unfocus(); // Removes focus
  //   final value = textController.text.trim();
  //   if (value.isNotEmpty) {
  //     // Your logic here (e.g., print or API call)
  //     print("Submitted: $value");
  //     Get.snackbar("Submitted", value,
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.blue[100]);
  //   } else {
  //     Get.snackbar("Error", "Text field is empty",
  //         snackPosition: SnackPosition.BOTTOM,
  //         backgroundColor: Colors.red[100]);
  //   }
  // }

  WebSocketChannel? _channel;

  final jointPositions = <String, RxDouble>{
    "Shoulder_Rotation": 0.0.obs,
    "Shoulder_Pitch": 0.0.obs,
    "Elbow": 0.0.obs,
    "Wrist_Pitch": 0.0.obs,
    "Wrist_Roll": 0.0.obs,
    "Gripper": 0.0.obs,
  };

  final jointLimits = {
    "Shoulder_Rotation": [-3.14, 3.14],
    "Shoulder_Pitch": [-1.57, 1.57],
    "Elbow": [-2.36, 2.36],
    "Wrist_Pitch": [-1.57, 1.57],
    "Wrist_Roll": [-3.14, 3.14],
    "Gripper": [-0.5, 0.5],
  };

  void connectWebSocket() async {
    isConnecting.value = true;
    try {
      FocusManager.instance.primaryFocus?.unfocus(); 
      getIp.write("rbip", textController.text);
      String rosbridgeUrl = "ws://${textController.text}:9090";
      print("Submitted: $rosbridgeUrl");
      _channel = WebSocketChannel.connect(Uri.parse(rosbridgeUrl));

      _channel!.stream.listen(
        (message) => print("Received: $message"),
        onDone: () {
          isConnected.value = false;
          isConnecting.value = false;
        },
        onError: (error) {
          print("WebSocket error: $error");
          isConnected.value = false;
          isConnecting.value = false;
        },
      );

      isConnected.value = true;
      isConnecting.value = false;
    } catch (e) {
      print("Connection failed: $e");
      isConnected.value = false;
      isConnecting.value = false;
    }
  }

  void disconnectWebSocket() {
    _channel?.sink.close(status.goingAway);
    isConnected.value = false;
    isConnecting.value = false;
  }

  void sendJointPositions() {
    if (!isConnected.value || _channel == null) return;

    final Map<String, dynamic> jsonData = {
      "op": "publish",
      "topic": "/joint_trajectory_controller/joint_trajectory",
      "msg": {
        "joint_names": jointPositions.keys.toList(),
        "points": [
          {
            "positions": jointPositions.values.map((v) => v.value).toList(),
            "velocities": [],
            "accelerations": [],
            "effort": [],
            "time_from_start": {"sec": 1, "nanosec": 0}
          }
        ]
      }
    };

    _channel!.sink.add(jsonEncode(jsonData));
    print("Sent: ${jsonData["msg"]["points"][0]["positions"]}");
  }

  void updateJoint(String joint, double value) {
    jointPositions[joint]?.value = value;
    if (continuousMode.value) {
      sendJointPositions();
    }
  }

  void resetAll() {
    jointPositions.forEach((key, value) => value.value = 0.0);
  }

  @override
void onInit() {
  super.onInit();
  if (getIp.hasData("rbip")) {
    textController.text = getIp.read("rbip");
  } else {
    textController.text = "";
  }
}


  @override
  void onClose() {
    _channel?.sink.close(status.goingAway);
    textController.dispose();
    super.onClose();
  }
}
