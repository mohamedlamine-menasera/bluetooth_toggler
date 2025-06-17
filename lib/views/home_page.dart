import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/bluetooth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the BluetoothController for changes to rebuild the UI
    final bluetoothController = context.watch<BluetoothController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Status App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display the main Bluetooth status
              Text(
                'Current Bluetooth Status:',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                bluetoothController.bluetoothStatus,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: bluetoothController.bluetoothStatus.contains('ON')
                      ? Colors.green
                      : bluetoothController.bluetoothStatus.contains('OFF')
                      ? Colors.orange
                      : Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Display error/guidance messages prominently
              if (bluetoothController.errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.red, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        bluetoothController.errorMessage,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Button to open Bluetooth settings
              ElevatedButton.icon(
                onPressed: bluetoothController.openSettings,
                icon: const Icon(Icons.settings_bluetooth),
                label: const Text(
                  'Open Bluetooth Settings',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}