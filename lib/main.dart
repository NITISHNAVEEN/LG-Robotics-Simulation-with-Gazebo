import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robocontrol/views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RoboControl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Homepage(),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:roslibdart/roslibdart.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ROS2 Joint Trajectory Publisher',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'ROS2 Joint Trajectory Publisher'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late Ros ros;
//   late Topic trajectoryTopic;
//   int messagesSent = 0;

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize ROS connection
//     ros = Ros(url: 'ws://10.0.2.2:9090');
    
//     // Create the joint trajectory topic
//     trajectoryTopic = Topic(
//       ros: ros,
//       name: '/joint_trajectory_controller/joint_trajectory',
//       type: "trajectory_msgs/msg/JointTrajectory",
//       reconnectOnClose: true,
//       queueLength: 10,
//       queueSize: 10
//     );
    
//     // Connect to ROS
//     ros.connect();
//   }

//   void sendTrajectory() async {
//     // Create the trajectory message
//     Map<String, dynamic> trajectoryMessage = {
//       "joint_names": [
//         "Shoulder_Rotation",
//         "Shoulder_Pitch", 
//         "Elbow",
//         "Wrist_Pitch",
//         "Wrist_Roll",
//         "Gripper"
//       ],
//       "points": [
//         {
//           "positions": [1.28, 0, -0.43, 0, 0, 0],
//           "velocities": [],
//           "accelerations": [],
//           "effort": [],
//           "time_from_start": {
//             "sec": 1,
//             "nanosec": 0
//           }
//         }
//       ]
//     };

//     // Publish the message
//     await trajectoryTopic.publish(trajectoryMessage);
    
//     // Update the counter
//     messagesSent++;
//     setState(() {});
    
//     print('Published trajectory message #$messagesSent');
//   }

//   @override
//   void dispose() {
//     ros.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Icon(
//               Icons.precision_manufacturing,
//               size: 80,
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               '5DOF Robotic Arm Controller',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: sendTrajectory,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 textStyle: const TextStyle(fontSize: 18),
//               ),
//               child: const Text('Send Trajectory'),
//             ),
//             const SizedBox(height: 30),
//             Text(
//               '$messagesSent messages sent',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }