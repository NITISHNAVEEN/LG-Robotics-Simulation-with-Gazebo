import 'package:get/get.dart';

class QrController extends GetxController {
  final qrData = ''.obs;

  void updateQrData(String data) {
    qrData.value = data;
    Get.back(); // Navigate back to previous screen
  }
}
