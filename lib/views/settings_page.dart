import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30.0),
        Center(
          child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                elevation: WidgetStatePropertyAll<double>(5.0),
                backgroundColor: WidgetStateProperty.all<Color>(
                  const Color.fromARGB(255, 120, 173, 252),
                ),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: const Text(
                "Scan your LG Rig QR Code",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
        ),
        SizedBox(height: 30.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No QR Data avaialable", 
          style: TextStyle(fontSize: 20.0),),
        ),
      ],
    );
  }
}