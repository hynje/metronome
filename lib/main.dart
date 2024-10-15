import 'package:flutter/material.dart';
import 'package:metronome/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 244, 244, 235),
          primaryColor: const Color.fromARGB(255, 252, 160, 0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 252, 160, 0),
          ),
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 252, 160, 0),
          )),
      home: const HomeScreen(),
    );
  }
}
