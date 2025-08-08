import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:robosim/views/robots/amiga.dart';
import 'package:robosim/views/robots/arm.dart';
import 'package:robosim/views/robots/arm_demo.dart';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  State<Controls> createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  // 1. Define the list of robot names
  final List<String> _robotNames = ['SO Arm 100 Interactive', 'SO Arm 100 Demo', 'AmigaBot'];
  
  // 2. Variable to hold the current selection
  late String _selectedRobot;

  @override
  void initState() {
    super.initState();
    // Initialize with the first robot in the list
    _selectedRobot = _robotNames.first;
  }

  // 3. Helper method to get the correct widget based on the name
  Widget _getselectedRobotWidget() {
    switch (_selectedRobot) {
      case 'SO Arm 100 Interactive':
        return const ArmExp();
      case 'SO Arm 100 Demo':
        return const ArmDemo();
      case 'AmigaBot':
        return const AmigaExp();
      default:
        return const Text("No robot selected or widget not found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: _selectedRobot,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // Update the state to trigger a rebuild
                    setState(() {
                      _selectedRobot = newValue;
                    });
                  }
                },
                items: _robotNames.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text("Model : $value"),
                  );
                }).toList(),
                
                isExpanded: true,
                underline: Container(), // Remove the underline
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              ),
              
              const SizedBox(height: 16),
      
              _getselectedRobotWidget(),
            ],
          ),
      ),
    );
  }
}