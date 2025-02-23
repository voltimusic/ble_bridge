import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'HomePage.dart';
import 'MidiLog.dart';

void main() {
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
