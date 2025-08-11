import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ControlsController extends GetxController {
  final isConnected = false.obs;
  final isConnecting = false.obs;
  final continuousMode = false.obs;
  final textController = TextEditingController();
  final getIp = GetStorage();

  WebSocketChannel? _channel;

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

  void sendJointPositions(String topicName, List jointPositions) {
    if (!isConnected.value || _channel == null) return;

    final Map<String, dynamic> jsonData = {
      "op": "publish",
      "topic": topicName,
      "msg": {
        "data": jointPositions,
      }
    };

    _channel!.sink.add(jsonEncode(jsonData));
    print("Sent: ${jsonData["msg"]["data"]}");
  }

  void sendOrder() {
    if (!isConnected.value || _channel == null) return;

    final Map<String, dynamic> jsonData = {
      "op": "publish",
      "topic": "/order",
      "msg": {
        "data": true,
      }
    };

    _channel!.sink.add(jsonEncode(jsonData));
    print("Sent: ${jsonData["msg"]["data"]}");
  }

}

