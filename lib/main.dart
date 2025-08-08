import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:robosim/controllers/controls.dart';
import 'package:robosim/controllers/robots/amiga_controller.dart';
import 'package:robosim/controllers/robots/arm_controller.dart';
import 'package:robosim/controllers/robots/arm_demo_controller.dart';
import 'package:robosim/views/home.dart';
import 'controllers/settings_controller.dart';

void main() async{
  await GetStorage.init();
  Get.put(ControlsController());
  Get.put(SettingsController());
  Get.put(ArmController());
  Get.put(AmigaController());
  Get.put(ArmDemoController());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoboControl',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 85, 85, 85)),
      ),
      home: Homepage(),
    );
  }
}
