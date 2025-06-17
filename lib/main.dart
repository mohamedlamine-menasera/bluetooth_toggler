import 'package:bluetooth_toggler/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/bluetooth_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Toggle App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Applying Inter font as per instructions
      ),
      home: const HomePage(),
    );
  }
}