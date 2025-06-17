import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings_plus/app_settings_plus.dart';

// Defines the BluetoothService class, responsible for handling Bluetooth-related
// logic such as checking permissions and opening system settings.
class BluetoothService {
  // Method to get the current Bluetooth permission status.
  // Returns true if BLUETOOTH_CONNECT permission is granted, false otherwise.
  // This permission is primarily for Android 12+ devices to allow connecting to devices.
  // For older devices (Android 6.0.1), BLUETOOTH and BLUETOOTH_ADMIN are typically
  // granted at install time for basic Bluetooth operations.
  Future<bool> requestBluetoothPermissions() async {
    // Request all relevant Bluetooth permissions for broader compatibility.
    // bluetoothScan, bluetoothAdvertise, bluetoothConnect are for Android 12+.
    // bluetooth (the general permission) is for older Android versions.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.locationWhenInUse, // Often required for Bluetooth scanning on Android
    ].request();

    // Check if at least the basic Bluetooth permission is granted.
    // For older devices, `Permission.bluetooth` is the primary one.
    // For newer devices, `bluetoothConnect` or `bluetoothScan` might be more specific.
    return statuses[Permission.bluetooth]?.isGranted == true ||
        statuses[Permission.bluetoothConnect]?.isGranted == true;
  }

  // Method to open the system's Bluetooth settings page.
  // This is the standard way to allow the user to manually enable/disable Bluetooth.
  Future<void> openBluetoothSettings() async {
    try {
      await AppSettingsPlus.openAppSettings(
        type: AppSettingsType.bluetooth, // Specify opening Bluetooth settings
      );
    } catch (e) {
      // Handle cases where opening settings might fail (e.g., on emulators without settings app)
      debugPrint('Error opening Bluetooth settings: $e');
      // In a real app, you might show a snackbar or dialog to the user here.
    }
  }

  // Method to get the current status of the Bluetooth adapter itself (on/off).
  // This uses serviceStatus from permission_handler, which is reliable for this purpose.
  Future<ServiceStatus> getBluetoothServiceStatus() async {
    return await Permission.bluetooth.serviceStatus;
  }
}