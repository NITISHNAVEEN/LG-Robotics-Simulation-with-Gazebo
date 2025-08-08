import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:robosim/views/controls.dart';
import 'package:robosim/views/lg_tools.dart';
import 'package:robosim/views/settings.dart';
import 'package:robosim/views/about.dart';
import 'package:robosim/controllers/nav_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final NavController controller = Get.put(NavController());

  final List<Widget> pages = [LgTools(), Controls(), Settings(), About()];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Stack(
            children: [
              // Bottom layer: Stroke (border)
              Text(
                'LG ROBOTICS',
                style: GoogleFonts.exo(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  foreground:
                      Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.black,
                ),
              ),
              // Top layer: Filled text
              Text(
                'LG ROBOTICS',
                style: GoogleFonts.exo(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 175, 175, 175),
        ),
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          selectedItemColor: const Color.fromARGB(255, 244, 128, 19),
          unselectedItemColor: const Color.fromARGB(255, 231, 230, 230),
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.control_camera_outlined, size: 32),
              activeIcon: Icon(Icons.control_camera_outlined, size: 32),
              label: 'LG Tools',
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
            BottomNavigationBarItem(
              icon: Icon(Icons.info, size: 32),
              activeIcon: Icon(Icons.info, size: 32),
              label: 'About',
            ),
          ],
        ),
      ),
    );
  }
}
