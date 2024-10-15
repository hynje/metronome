import 'package:flutter/material.dart';
import 'package:metronome/widgets/metronome.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double defaultBpm = 265;
  int defaultBeat = 4, defaultNote = 4;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.amber.shade100,
        //foregroundColor: Colors.brown.shade600,
        title: const Text(
          'Metronome',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Metronome(
              bpm: defaultBpm,
              beat: defaultBeat,
              note: defaultNote,
            ),
          ],
        ),
      ),
    );
  }
}
