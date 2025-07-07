
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:robocontrol/controllers/settings_controller.dart';

class AlternativeQRWidget extends StatelessWidget {
  const AlternativeQRWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController qrController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: _MobileScannerView(controller: qrController),
    );
  }
}

class _MobileScannerView extends StatefulWidget {
  final SettingsController controller;

  const _MobileScannerView({required this.controller});

  @override
  State<_MobileScannerView> createState() => _MobileScannerViewState();
}

class _MobileScannerViewState extends State<_MobileScannerView> {
  MobileScannerController scannerController = MobileScannerController();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: scannerController,
          onDetect: _onDetect,
        ),
        if (_isScanning)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Processing QR Code...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                color: Colors.white,
                icon: ValueListenableBuilder(
                  valueListenable: scannerController.torchState,
                  builder: (context, state, child) {
                    switch (state) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off, color: Colors.grey);
                      case TorchState.on:
                        return const Icon(Icons.flash_on, color: Colors.yellow);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () => scannerController.toggleTorch(),
              ),
              IconButton(
                color: Colors.white,
                icon: ValueListenableBuilder(
                  valueListenable: scannerController.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                iconSize: 32.0,
                onPressed: () => scannerController.switchCamera(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _isScanning = true;
        });
        
        print("QR Code detected: ${barcode.rawValue}");
        
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.controller.setQRCode(barcode.rawValue!);
        });
        break;
      }
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}