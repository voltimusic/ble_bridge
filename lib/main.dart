import 'dart:io';


import 'package:ble_bridge_volti/safty/MacOSSecurity.dart';
import 'package:ble_bridge_volti/safty/SecurityWarningScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'HomePage.dart';
import 'MidiLog.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS)
    {
      // ✅ Only run security checks on macOS
      String? securityError = await MacOSSecurity.runSecurityChecks();
      if (securityError != null) {
        runApp(SecurityErrorScreen(errorMessage: securityError));
        return;
      }
    }


  // ✅ If not macOS, or security checks pass, run app normally
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MidiLogProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIDI Bridge App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'), // Path to your image
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          child: HomePage(), // Your HomePage or other content
        ),
      ),
    );
  }
}
