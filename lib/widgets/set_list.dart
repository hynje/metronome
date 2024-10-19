import 'package:flutter/material.dart';

class Setlist extends StatefulWidget {
  const Setlist({super.key});

  @override
  State<Setlist> createState() => _SetlistState();
}

class _SetlistState extends State<Setlist> {
  final List<String> items =
      List<String>.generate(10, (index) => "Item $index");
  int iSelected = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 18),
          ),
          title: const Text('song_title'),
          subtitle: const Text('bpm = xx'),
          //trailing: const Icon(Icons.arrow_forward),
          selected: index == iSelected,
          onTap: () {
            iSelected = index;
            setState(() {});
          },
        );
      },
    );
  }
}
