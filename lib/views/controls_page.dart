import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ControlsPage extends StatelessWidget {
  const ControlsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RobotController();
  }
}

class RobotController extends StatefulWidget {
  const RobotController({super.key});

  @override
  State<RobotController> createState() => _RobotControllerState();
}

class _RobotControllerState extends State<RobotController> {
  WebSocketChannel? channel;
  bool isConnected = false;
  bool isConnecting = false;

  // Joint position values
  final Map<String, double> jointPositions = {
    "Shoulder_Rotation": 0.0,
    "Shoulder_Pitch": 0.0,
    "Elbow": 0.0,
    "Wrist_Pitch": 0.0,
    "Wrist_Roll": 0.0,
    "Gripper": 0.0,
  };

  // Joint limits (in radians)
  final Map<String, List<double>> jointLimits = {
    "Shoulder_Rotation": [-3.14, 3.14],
    "Shoulder_Pitch": [-1.57, 1.57],
    "Elbow": [-2.36, 2.36],
    "Wrist_Pitch": [-1.57, 1.57],
    "Wrist_Roll": [-3.14, 3.14],
    "Gripper": [-0.5, 0.5],
  };

  void connectWebSocket() async {
    setState(() {
      isConnecting = true;
    });

    try {
      channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:9090'));
      
      channel!.stream.listen(
        (message) {
          debugPrint("Received: $message");
        },
        onDone: () {
          debugPrint("WebSocket closed");
          setState(() {
            isConnected = false;
            isConnecting = false;
          });
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          setState(() {
            isConnected = false;
            isConnecting = false;
          });
        },
      );

      setState(() {
        isConnected = true;
        isConnecting = false;
      });
    } catch (e) {
      debugPrint("Connection failed: $e");
      setState(() {
        isConnected = false;
        isConnecting = false;
      });
    }
  }

  void disconnectWebSocket() {
    channel?.sink.close(status.goingAway);
    setState(() {
      isConnected = false;
      isConnecting = false;
    });
  }

  void sendJointPositions() {
    if (!isConnected || channel == null) return;

    final List<double> positions = jointPositions.values.toList();

    final Map<String, dynamic> jsonData = {
      "op": "publish",
      "topic": "/joint_trajectory_controller/joint_trajectory",
      "msg": {
        "joint_names": jointPositions.keys.toList(),
        "points": [
          {
            "positions": positions,
            "velocities": [],
            "accelerations": [],
            "effort": [],
            "time_from_start": {"sec": 1, "nanosec": 0}
          }
        ]
      }
    };

    channel!.sink.add(jsonEncode(jsonData));
    debugPrint("Joint positions sent: $positions");
  }

  void resetJointPositions() {
    setState(() {
      for (String joint in jointPositions.keys) {
        jointPositions[joint] = 0.0;
      }
    });
  }

  @override
  void dispose() {
    channel?.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Robot Joint Controller",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isConnected ? "Connected" : "Disconnected",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const Spacer(),
                      if (isConnecting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isConnected || isConnecting ? null : connectWebSocket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isConnecting ? "Connecting..." : "Connect",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isConnected ? disconnectWebSocket : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Disconnect",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Joint Controls Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Joint Positions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Joint Sliders
                  ...jointPositions.keys.map((joint) {
                    final limits = jointLimits[joint]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                joint.replaceAll('_', ' '),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "${jointPositions[joint]!.toStringAsFixed(2)} rad",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.blue[600],
                              inactiveTrackColor: Colors.grey[200],
                              thumbColor: Colors.blue[600],
                              overlayColor: Colors.blue[600]?.withOpacity(0.1),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: jointPositions[joint]!,
                              min: limits[0],
                              max: limits[1],
                              onChanged: (value) {
                                setState(() {
                                  jointPositions[joint] = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: resetJointPositions,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            "Reset All",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isConnected ? sendJointPositions : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Send to Robot",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}