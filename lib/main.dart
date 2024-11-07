import 'package:flutter/material.dart';
import 'package:metronome/ad_manager.dart';
import 'package:metronome/provider.dart';
import 'package:metronome/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  AdManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 244, 244, 235),
          primaryColor: const Color.fromARGB(255, 252, 160, 0),
          appBarTheme: const AppBarTheme(
            foregroundColor: Colors.brown,
            backgroundColor: Color.fromARGB(255, 252, 160, 0),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Color.fromARGB(255, 252, 160, 0),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 252, 160, 0),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
