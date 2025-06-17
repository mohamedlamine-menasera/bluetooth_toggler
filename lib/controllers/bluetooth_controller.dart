import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/bluetooth_service.dart';

// BluetoothController manages the state related to Bluetooth,
// interacting with BluetoothService and notifying listeners of changes.
class BluetoothController extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  String _bluetoothStatus = 'Initializing...'; // Initial status message
  String _errorMessage = ''; // Message for specific errors or prompts

  // Getters for the UI to access status and error messages
  String get bluetoothStatus => _bluetoothStatus;
  String get errorMessage => _errorMessage;

  BluetoothController() {
    // Initialize by updating Bluetooth status when the controller is created.
    _updateBluetoothStatus();
    // Listen for changes in Bluetooth adapter state and app permissions.
    // This allows the UI to react if the user changes Bluetooth via quick settings
    // or modifies permissions.
    Permission.bluetooth.status.asStream().listen((status) {
      _updateBluetoothStatus();
    });
    // Also listen to the service status (Bluetooth on/off)
    Permission.bluetooth.serviceStatus.asStream().listen((serviceStatus) {
      _updateBluetoothStatus();
    });
  }

  // Requests necessary Bluetooth permissions and updates the status.
  Future<void> _updateBluetoothStatus() async {
    _errorMessage = ''; // Clear previous error messages
    notifyListeners(); // Notify listeners to clear old error messages immediately

    bool hasPermission = await _bluetoothService.requestBluetoothPermissions();
    if (!hasPermission) {
      _bluetoothStatus = 'Bluetooth Permission Needed';
      _errorMessage = 'Please grant Bluetooth permissions in app settings.';
      notifyListeners();
      return;
    }

    // Now check the actual Bluetooth adapter service status (on/off)
    ServiceStatus serviceStatus = await _bluetoothService.getBluetoothServiceStatus();

    switch (serviceStatus) {
      case ServiceStatus.enabled:
        _bluetoothStatus = 'Bluetooth is ON';
        _errorMessage = ''; // No error if enabled
        break;
      case ServiceStatus.disabled:
        _bluetoothStatus = 'Bluetooth is OFF';
        _errorMessage = 'Bluetooth is currently off. Tap below to enable.';
        break;
      case ServiceStatus.notApplicable:
        _bluetoothStatus = 'Bluetooth Not Available';
        _errorMessage = 'This device does not support Bluetooth.';
        break;
      default:
        _bluetoothStatus = 'Bluetooth Status Unknown';
        _errorMessage = 'Could not determine Bluetooth status.';
        break;
    }
    notifyListeners(); // Notify UI of status and error message changes
  }

  // Opens the system Bluetooth settings.
  void openSettings() {
    _bluetoothService.openBluetoothSettings();
  }
}
