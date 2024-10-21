import 'package:flutter/material.dart';
import 'package:metronome/widgets/metronome.dart';
import 'package:metronome/widgets/set_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Metronome',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: const Stack(
        children: [
          Metronome(),
          Center(
            child: SetList(),
          ),
        ],
      ),
    );
  }
}
