import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dartssh2/dartssh2.dart';

class SettingsController extends GetxController {
  var qrCode = "".obs;
  var sshConnected = false.obs;
  final ipController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final sshPortController = TextEditingController();
  final rigsController = TextEditingController();

  late String _host;
  late String _username;
  late String _password;
  late String _port;
  late String _rigs;
  SSHClient? _client;

  final sshModel = GetStorage();

  void saveDetails() {
    if (sshModel.read("lg_host") != ipController.text){
      sshModel.write("lg_host", ipController.text);
    }
    if (sshModel.read("lg_username") != usernameController.text){
      sshModel.write("lg_username", usernameController.text);
    }
    if (sshModel.read("lg_password") != passwordController.text){
      sshModel.write("lg_password", passwordController.text);
    }
    if (sshModel.read("lg_port") != sshPortController.text){
      sshModel.write("lg_port", sshPortController.text);
    }
    if (sshModel.read("lg_rigs") != rigsController.text){
      sshModel.write("lg_rigs", rigsController.text);
    }
  }

  Future<void> connectLg() async {
    saveDetails();
    _host = sshModel.read("lg_host");
    _username = sshModel.read("lg_username");
    _password = sshModel.read("lg_password");
    _port = sshModel.read("lg_port");
    _rigs = sshModel.read("lg_rigs");

    try {
      final socket = await SSHSocket.connect(
        _host,
        int.parse(_port),
      ).timeout(const Duration(seconds: 8));

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _password,
      );
    } catch (e) {
      sshConnected.value = false;
    }
    Get.snackbar("Connection Successfull", "You are now successfully connected to Liquid Galaxy Rig", backgroundColor: const Color.fromARGB(255, 128, 255, 132));
    sshConnected.value = true;
  }

  Future<void> disconnect() async {
    // if (await isConnected()) {
      _client!.close();
      sshConnected.value = false;
    // }
  }


  



  void setQRCode(String code) {
    // print("QR Controller - Setting QR Code: $code");
    qrCode.value = code;
    // print("QR Controller - QR Code set to: ${qrCode.value}");
    
    // Add a small delay to ensure the value is set before navigating back
    Future.delayed(const Duration(milliseconds: 100), () {
      // print("QR Controller - Navigating back");
      Get.back(); // Go back to previous screen (SettingsPage)
    });
  }
  
  // @override
  // void onInit() {
  //   super.onInit();
  //   print("QR Controller initialized");
  // }
}