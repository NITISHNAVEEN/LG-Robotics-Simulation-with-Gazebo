import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:robosim/controllers/controls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

class SettingsController extends GetxController {
  final ControlsController controlsController = Get.find();
  var qrCode = "".obs;
  var sshConnected = false.obs;
  final ipController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final sshPortController = TextEditingController();
  final rigsController = TextEditingController();

  // final streamIpController = TextEditingController();

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

  // Helper function for confirmation dialogs
  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await Get.defaultDialog<bool>(
      title: title,
      middleText: content,
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(color: Colors.black87),
      middleTextStyle: const TextStyle(color: Colors.black54),
      actions: [
      ElevatedButton(
        onPressed: () => Get.back(result: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text("Yes"),
      ),
      OutlinedButton(
        onPressed: () => Get.back(result: false),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text("No"),
      ),
    ],
      radius: 10,
    );
    // Return false if the dialog is dismissed (result is null)
    return result ?? false;
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
    final confirmed = await _showConfirmationDialog(
        'Confirm Shutdown', 'Are you sure you want to shut down the LG Rig?');
    if (!confirmed) return;
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
  } finally {
        sshConnected.value = false;
  }}

  Future<void> reboot() async {
    final confirmed = await _showConfirmationDialog(
        'Confirm Reboot', 'Are you sure you want to reboot the LG Rig?');
    if (!confirmed) return;
    final String pw = _password;
    if (!await isConnected()) {
      return;
    }
    sshConnected.value = false;
    for  (var i = int.parse(_rigs); i >=1; i--) {
      await sendCommand(
          'sshpass -p $pw ssh -t lg$i "echo $pw | sudo -S reboot"');
    }
  }

  Future<void> relaunch() async {
    final confirmed = await _showConfirmationDialog(
        'Confirm Relaunch', 'Are you sure you want to relaunch the LG Rig?');
    if (!confirmed) return; 
        final String pw = _password;

        if (!await isConnected()) {
          return;
        }

        final user = _username;

        for (var i = int.parse(_rigs); i >= 1; i--) {
          final relaunchCommand = """RELAUNCH_CMD="\\
    if [ -f /etc/init/lxdm.conf ]; then
      export SERVICE=lxdm
    elif [ -f /etc/init/lightdm.conf ]; then
      export SERVICE=lightdm
    else
      exit 1
    fi
    if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
      echo $pw | sudo -S service \\\${SERVICE} start
    else
      echo $pw | sudo -S service \\\${SERVICE} restart
    fi
    " && sshpass -p $pw ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
          await sendCommand('"/home/$user/bin/lg-relaunch" > /home/$user/log.txt');
          await sendCommand(relaunchCommand);
        }
      }

  Future<void> launchStream() async {
    final String pw = _password;
    if (!await isConnected()) {
      return;
    }

    String streamIp = controlsController.textController.text;
    // String streamIp = "10.145.2.254";

      if (streamIp.isEmpty) {
        Get.snackbar(
          "Invalid Stream IP/Not connected to Server",
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

      await sendCommand('sshpass -p $pw ssh -t lg$i "pkill -f chromium-browser"');

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
      ipController.text = data["ip"].toString(); 
      usernameController.text = data["username"].toString();
      passwordController.text = data["password"].toString();
      sshPortController.text = data["port"].toString(); 
      rigsController.text = data["screens"].toString(); 
      } else{
        Get.snackbar("Error", "Invalid QR Code format");
      }
    // Add a small delay to ensure the value is set before navigating back
    Future.delayed(const Duration(milliseconds: 100), () {
      // print("QR Controller - Navigating back");
      Get.back(); // Go back to previous screen (SettingsPage)
    });
  }

  final zoomLevel = 1.0.obs;
  final isconnectedsocket = false.obs;
  final isconnectingsocket = false.obs;
  IO.Socket? socket;

  // --- Public Methods ---

  void connectSocket() {
    if (isconnectedsocket.value || isconnectingsocket.value) return;

    isconnectingsocket.value = true;
    final serverUrl = "http://${controlsController.textController.text}:8080";

    socket = IO.io(serverUrl, {
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': false,
    });

    socket!.onConnect((_) {
      isconnectedsocket.value = true;
      isconnectingsocket.value = false;
      print("✅ Connected to server.");
    });

    socket!.onDisconnect((_) {
      isconnectedsocket.value = false;
      print("🔌 Disconnectedsocket from server.");
    });

    socket!.onConnectError((err) {
      isconnectingsocket.value = false;
      print("❌ Connection error: $err");
    });

    socket!.connect();
  }

  void disconnectSocket() {
    socket?.disconnect();
}

void toggleSocketConnection() {
    if (isconnectedsocket.value) {
        disconnectSocket();
    } else {
        connectSocket();
    }
}

  void showLogo() {
    // Change this to match the server
    _emitIfConnected('toggle_overlay', {'show': true});
  }

  void clearLogo() {
    // Change this to match the server
    _emitIfConnected('toggle_overlay', {'show': false});
  }

  void _emitIfConnected(String event, [dynamic data]) {
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
      print("✅ Emitted: $event ${data ?? ''}");
    } else {
      print("❌ Not connected. Cannot emit $event.");
    }
  }

  void transmitZoomLevel() {
    _emitIfConnected('set_zoom', {'level': zoomLevel.value});
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
    if (sshModel.hasData("lg_host") && sshModel.hasData("lg_username")) {
      connectLg();
    }
    // debounce(zoomLevel, (_) => transmitZoomLevel(),
    //     time: const Duration(milliseconds: 200)); // Debounce to prevent flooding the server
  
  }

  @override
  void onClose() {
    ipController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    sshPortController.dispose();
    rigsController.dispose();
    socket?.disconnect();
    super.onClose();
  }
}