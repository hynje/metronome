import 'package:flutter/material.dart';
import 'package:metronome/widgets/banner_ad.dart';
import 'package:metronome/widgets/metronome.dart';
import 'package:metronome/widgets/set_list.dart';
import 'package:metronome/ad_manager.dart';

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Metronome',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          FullWidthBannerAd(
            bannerAd: AdManager.instance.appBarAd,
          ),
          const Metronome(),
          const Center(
            child: SetList(),
          ),
        ],
      ),
    );
  }
}
