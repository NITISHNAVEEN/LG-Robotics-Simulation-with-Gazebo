import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robocontrol/controllers/nav_controller.dart';
import 'package:robocontrol/views/controls_page.dart';
import 'package:robocontrol/views/settings_page.dart';
import 'package:robocontrol/views/views_page.dart';
import 'package:robocontrol/controllers/settings_controller.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final NavController controller = Get.put(NavController());

  final List<Widget> pages = [
    ViewsPage(),
    ControlsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    return Obx(() => Scaffold(
          appBar: AppBar(
            title: const Text(
              'LG Robotics',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color.fromARGB(255, 250, 224, 199),
          ),
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 250, 224, 199),
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black.withAlpha(80),
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.control_camera_outlined, size: 32),
                activeIcon: Icon(Icons.control_camera_outlined, size: 32),
                label: 'Views',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.gamepad, size: 32),
                activeIcon: Icon(Icons.gamepad, size: 32),
                label: 'Controls',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings, size: 32),
                activeIcon: Icon(Icons.settings, size: 32),
                label: 'Settings',
              ),
            ],
          ),
        ));
  }
}