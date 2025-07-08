import 'package:get/get.dart';
import 'dart:convert';
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

  final streamIpController = TextEditingController();

  late String _host;
  late String _username;
  late String _password;
  late String _port;
  late String _rigs;
  int? _totalRigs;
  SSHClient? _client;
  late int _streamPort;

  final sshModel = GetStorage();

  void saveDetails() {
    if (sshModel.read("lg_host") != ipController.text) {
      sshModel.write("lg_host", ipController.text);
    }
    if (sshModel.read("lg_username") != usernameController.text) {
      sshModel.write("lg_username", usernameController.text);
    }
    if (sshModel.read("lg_password") != passwordController.text) {
      sshModel.write("lg_password", passwordController.text);
    }
    if (sshModel.read("lg_port") != sshPortController.text) {
      sshModel.write("lg_port", sshPortController.text);
    }
    if (sshModel.read("lg_rigs") != rigsController.text) {
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

      _totalRigs = int.tryParse(_rigs);
      if (_totalRigs != null) {
        print("Parsed: $_totalRigs");
      } else {
        print("Invalid integer string");
        throw Exception("Invalid Number of Rigs");
      }

      _client = SSHClient(
        socket,
        username: _username,
        onPasswordRequest: () => _password,
      );
    } catch (e) {
      sshConnected.value = false;
      Get.snackbar(
        "Connection Failed",
        "Could not connect to Liquid Galaxy Rig",
        backgroundColor: const Color.fromARGB(255, 250, 121, 104),
      );
      return;
    }
    Get.snackbar(
      "Connection Successfull",
      "You are now successfully connected to Liquid Galaxy Rig",
      backgroundColor: const Color.fromARGB(255, 128, 255, 132),
    );
    sshConnected.value = true;
  }

  Future<void> disconnect() async {
    // if (await isConnected()) {
    _client!.close();
    sshConnected.value = false;
    // }
  }

  Future<bool> isConnected() async {
    if (_client == null || _client!.isClosed) return false;
    try {
      // Attempt to execute a simple command to check the connection status
      final result = await sendCommand('echo "check connection"');
      print(result);
      return result != null;
    } catch (e) {
      // If an exception occurs, the connection is not active
      return false;
    }
  }

  Future<String?> sendCommand(String command) async {
    try {
      print("sending command: $command");
      return utf8.decode(await _client!.run(command));
    } on SSHChannelOpenError {
      await handleSSHChannelOpenError();
      return utf8.decode(await _client!.run(command));
    } catch (e) {
      return null;
    }
  }

  Future<SSHSession?> execute(String command) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }
      print("executing");
      final session = _client!.execute(command);
      print("execution complete");
      return session;
    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  Future<void> shutdown() async {
    final String pw = _password;
    if (!await isConnected()) {
      return;
    }

    
    try {
        // First send shutdown commands
        for (var i = int.parse(_rigs); i >= 1; i--) {
            await sendCommand(
                'sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S poweroff"'
            );
        }
        
        // Properly close the SSH connection
        await disconnect();        
        
    } catch (e) {
        print('Shutdown error: $e');
        // Still try to close connection even if shutdown command fails
        await disconnect();
  }}

  Future<void> reboot() async {
    final String pw = _password;
    if (!await isConnected()) {
      return;
    }

    for  (var i = int.parse(_rigs); i >=1; i--) {
      await sendCommand(
          'sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S reboot"');
    }
  }

  Future<void> launchStream() async {
    final String pw = _password;
    if (!await isConnected()) {
      return;
    }

    String streamIp = streamIpController.text;

      if (streamIp.isEmpty) {
        Get.snackbar(
          "Invalid Stream IP",
          "Please enter a valid Stream IP",
          backgroundColor: const Color.fromARGB(255, 250, 121, 104),
        );
        return;
      }

    for  (var i = int.parse(_rigs); i >=1; i--) {
      if(i>((_totalRigs!/2)+1)){
        _streamPort = 8083-(_totalRigs!-i+1);
      }
      else{
        _streamPort = 8083+i-1;
      }

      sendCommand(
        'sshpass -p $pw ssh -t lg$i "DISPLAY=:0 chromium-browser --start-fullscreen $streamIp:$_streamPort"'
      );
    }
  }

  Future<void> closeStream() async {
    final String pw = _password;
    if (!await isConnected()) {
      return;
    }

    for  (var i = int.parse(_rigs); i >=1; i--) {
      await sendCommand(
    'sshpass -p $pw ssh -t lg$i "pkill -f chromium-browser"'
  );
    }
  }

  Future<void> handleSSHChannelOpenError() async {
    await disconnect();
    await connectLg();
  }



  /* a function to check if the QR Code is of the format of {
      "username": "YOUR_USERNAME",
      "ip": "192.168.XX.XXX",
      "port": "YOUR_PORT",
      "password": "YOUR_ACTUAL_PASSWORD",
      "screens": "3"
    }*/
  checkvalid(String code) {
    try {
      final data = json.decode(code);
      return data["username"] != null &&
          data["ip"] != null &&
          data["port"] != null &&
          data["password"] != null &&
          data["screens"] != null;
    } catch (e) {
      return false;
    }
  }

  void setQRCode(String code) {
    // print("QR Controller - Setting QR Code: $code");
    qrCode.value = code;
    // print("QR Controller - QR Code set to: ${qrCode.value}");
    if (checkvalid(code)) {
      // print("QR Controller - QR Code is valid");
      final data = json.decode(code);
      ipController.text = data["ip"];
      usernameController.text = data["username"];
      passwordController.text = data["password"];
      sshPortController.text = data["port"];
      rigsController.text = data["screens"];
    }
    // Add a small delay to ensure the value is set before navigating back
    Future.delayed(const Duration(milliseconds: 100), () {
      // print("QR Controller - Navigating back");
      Get.back(); // Go back to previous screen (SettingsPage)
    });
  }

  @override
  void onInit() {
    super.onInit();
    if (sshModel.hasData("lg_host")) {
      ipController.text = sshModel.read("lg_host");
    }
    if (sshModel.hasData("lg_username")) {
      usernameController.text = sshModel.read("lg_username");
    }
    if (sshModel.hasData("lg_password")) {
      passwordController.text = sshModel.read("lg_password");
    }
    if (sshModel.hasData("lg_port")) {
      sshPortController.text = sshModel.read("lg_port");
    }
    if (sshModel.hasData("lg_rigs")) {
      rigsController.text = sshModel.read("lg_rigs");
    }
  }

  @override
  void onClose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    sshPortController.dispose();
    rigsController.dispose();
    super.onClose();
  }
}