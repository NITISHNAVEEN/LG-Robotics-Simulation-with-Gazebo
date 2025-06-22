import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robocontrol/controllers/nav_controller.dart';
import 'package:robocontrol/views/controls_page.dart';
import 'package:robocontrol/views/settings_page.dart';
import 'package:robocontrol/views/views_page.dart';

class Homepage extends StatelessWidget {
  
  final NavController controller = Get.put(NavController());

  final List<Widget> pages = [
    ViewsPage(),
    ControlsPage(),
    SettingsPage(),
  ];

  Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: const Text('LG Robotics',
        style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),),
        backgroundColor: const Color.fromARGB(255, 221, 210, 200),
      ),
          body: pages[controller.selectedIndex.value],
          bottomNavigationBar: BottomNavigationBar(

            backgroundColor: const Color.fromARGB(255, 221, 210, 200),
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black.withValues(alpha: 0.2),

            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.control_camera_outlined,
                  size: 32,
                ),
                activeIcon: Icon(
                  Icons.control_camera_outlined,
                  size: 32,
                ),
                label: 'Views',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.gamepad,
                  size: 32,
                ),
                activeIcon: Icon(
                  Icons.gamepad,
                  size: 32,
                ),
                label: 'Controls',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 32,
                ),
                activeIcon: Icon(
                  Icons.settings,
                  size: 32,
                ),
                label: 'Settings',
              ),
            ],
          ),
        )
    );
  }
}