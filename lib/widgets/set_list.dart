import 'package:flutter/material.dart';
import 'package:metronome/provider.dart';
import 'package:provider/provider.dart';

class SetList extends StatefulWidget {
  const SetList({super.key});

  @override
  State<SetList> createState() => _SetListState();
}

class _SetListState extends State<SetList> {
  final List<double> bpmList = <double>[
    60,
    70,
    80,
    90,
    100,
    120,
    130,
    140,
    150,
    160
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          margin: const EdgeInsets.only(top: 110, bottom: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.brown.shade600),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: bpmList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text('${index + 1}'),
                title: const Text('song title'),
                subtitle: Text('${bpmList[index]} bpm'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  appState.setBpm(bpmList[index]);
                },
              );
            },
          ),
        );
      },
    );
  }
}
