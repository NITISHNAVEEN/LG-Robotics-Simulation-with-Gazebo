import 'package:get/get.dart';

class QRController extends GetxController {
  var qrCode = "".obs;

  void setQRCode(String code) {
    print("QR Controller - Setting QR Code: $code");
    qrCode.value = code;
    print("QR Controller - QR Code set to: ${qrCode.value}");
    
    // Add a small delay to ensure the value is set before navigating back
    Future.delayed(const Duration(milliseconds: 100), () {
      print("QR Controller - Navigating back");
      Get.back(); // Go back to previous screen (SettingsPage)
    });
  }
  
  @override
  void onInit() {
    super.onInit();
    print("QR Controller initialized");
  }
}