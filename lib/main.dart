// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Import the Flutter Blue Plus plugin

// bluetooth_model.dart
class BluetoothModel {
  // Returns the current Bluetooth state (on/off, unavailable, etc.)
  Stream<BluetoothAdapterState> get adapterStateStream =>
      FlutterBluePlus.adapterState;

  // Tries to turn on Bluetooth. On newer Android, this might prompt the user.
  // On older Android, it will attempt direct enabling.
  Future<void> enableBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      debugPrint("Error turning on Bluetooth: $e");
      // Handle potential errors, e.g., Bluetooth not available or permission denied.
      // In a real app, you might show a user-friendly message.
    }
  }

  // Tries to turn off Bluetooth. On newer Android, this might prompt the user.
  // On older Android, it will attempt direct disabling.
  Future<void> disableBluetooth() async {
    try {
      await FlutterBluePlus.turnOff();
    } catch (e) {
      debugPrint("Error turning off Bluetooth: $e");
      // Handle potential errors.
    }
  }
}

// bluetooth_controller.dart
class BluetoothController extends ChangeNotifier {
  final BluetoothModel _model = BluetoothModel();
  BluetoothAdapterState _currentState = BluetoothAdapterState.unknown;

  BluetoothController() {
    // Listen to changes in the Bluetooth adapter state
    _model.adapterStateStream.listen((state) {
      _currentState = state;
      notifyListeners(); // Notify listeners (the UI) of the state change
    });
    // Request permissions upfront if they are not granted
    _requestPermissions();
  }

  // Get the current Bluetooth adapter state
  BluetoothAdapterState get currentState => _currentState;

  // Check if Bluetooth is currently on
  bool get isBluetoothOn => _currentState == BluetoothAdapterState.on;

  // Toggle Bluetooth state
  Future<void> toggleBluetooth() async {
    if (_currentState == BluetoothAdapterState.on) {
      await _model.disableBluetooth();
    } else if (_currentState == BluetoothAdapterState.off) {
      await _model.enableBluetooth();
    } else {
      debugPrint("Bluetooth state is $_currentState, cannot toggle directly.");
      // Potentially show a message to the user about an unknown or unavailable state
    }
  }

  // Request necessary Bluetooth permissions
  Future<void> _requestPermissions() async {
    // Check if Bluetooth is available on the device
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("Bluetooth not supported on this device.");
      // In a real app, show a message to the user.
      return;
    }

    // Request permissions required for Bluetooth operations.
    // FlutterBluePlus handles runtime permission requests for Android 12+
    // (BLUETOOTH_SCAN, BLUETOOTH_CONNECT).
    // For older Android, BLUETOOTH and BLUETOOTH_ADMIN are typically
    // granted at install time (normal permissions).
    await FlutterBluePlus.turnOn(); // This implicitly handles some permission checks and requests.
  }
}

// bluetooth_view.dart
class BluetoothView extends StatelessWidget {
  const BluetoothView({super.key});

  // Helper method to get a user-friendly status message
  String _getStatusMessage(BluetoothAdapterState state) {
    switch (state) {
      case BluetoothAdapterState.unavailable:
        return "Bluetooth Unavailable";
      case BluetoothAdapterState.unauthorized:
        return "Bluetooth Unauthorized";
      case BluetoothAdapterState.turningOn:
        return "Bluetooth Turning On...";
      case BluetoothAdapterState.on:
        return "Bluetooth On";
      case BluetoothAdapterState.turningOff:
        return "Bluetooth Turning Off...";
      case BluetoothAdapterState.off:
        return "Bluetooth Off";
      case BluetoothAdapterState.unknown:
      default:
        return "Bluetooth Unknown State";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the BluetoothController for changes
    final controller = Provider.of<BluetoothController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Toggler'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display current Bluetooth status
              Text(
                _getStatusMessage(controller.currentState),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Button to toggle Bluetooth
              ElevatedButton(
                onPressed: () {
                  // Call the toggleBluetooth method in the controller
                  controller.toggleBluetooth();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isBluetoothOn
                      ? Colors.redAccent
                      : Colors.green, // Change color based on state
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  controller.isBluetoothOn ? 'Turn Off Bluetooth' : 'Turn On Bluetooth',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              // Optional: Show a hint for newer Android versions
              if (controller.currentState == BluetoothAdapterState.off ||
                  controller.currentState == BluetoothAdapterState.on)
                const Text(
                  "(On Android 12+, enabling/disabling may require user confirmation via system dialog.)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// main.dart continues...
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter widgets are initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provide the BluetoothController to the widget tree
      create: (context) => BluetoothController(),
      child: MaterialApp(
        title: 'Bluetooth Toggler',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Inter', // Custom font
        ),
        home: const BluetoothView(),
      ),
    );
  }
}