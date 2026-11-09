import 'package:flutter/material.dart';

import '../widgets/beat_indicator.dart';
import '../widgets/bpm_control.dart';
import '../widgets/set_list_view.dart';
import '../widgets/transport_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Metronome',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: const SafeArea(
        top: false,
        // 키보드가 올라와도 하단 여백이 바뀌어 화면이 흔들리지 않게 한다.
        maintainBottomViewPadding: true,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: BeatIndicator(),
              ),
              Expanded(child: SetListView()),
              SizedBox(height: 16),
              BpmControl(),
              TransportBar(),
            ],
          ),
        ),
      ),
    );
  }
}
